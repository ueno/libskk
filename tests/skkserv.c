#include <libskk/libskk.h>
#include <string.h>
#include <gio/gio.h>

struct _SkkServTransaction {
  gchar *request;
  gchar *response;
};
typedef struct _SkkServTransaction SkkServTransaction;

struct _SkkServData {
  GSocket *server;
  GThread *thread;
  SkkServTransaction *transactions;
  gsize n_transactions;
};
typedef struct _SkkServData SkkServData;

static gpointer
skkserv_thread (gpointer user_data)
{
  SkkServData *data = user_data;
  GSocket *socket;
  GError *error = NULL;
  gssize nread;
  gchar buf[4096];              /* large enough */
  GSocketConnection *connection;
  GOutputStream *output;

  socket = g_socket_accept (data->server, NULL, &error);
  g_assert_no_error (error);
  connection = g_socket_connection_factory_create_connection (socket);
  output = g_io_stream_get_output_stream (G_IO_STREAM (connection));

  while (TRUE)
    {
      gint i;

      nread = g_socket_receive (socket, buf, sizeof (buf), NULL, &error);
      g_assert_no_error (error);
      g_assert_cmpint (nread, >=, 0);

      if (nread == 0)
	break;

      for (i = 0; i < data->n_transactions; i++)
        {
          gsize bytes_written;
          SkkServTransaction *transaction = &data->transactions[i];
          if (strncmp (buf, transaction->request, nread) == 0)
            {
              error = NULL;
              g_output_stream_write_all (output,
                                         transaction->response,
                                         strlen (transaction->response),
                                         &bytes_written,
                                         NULL,
                                         &error);
              g_assert_no_error (error);
              g_output_stream_flush (output, NULL, &error);
              g_assert_no_error (error);
              break;
            }
        }
    }

  g_object_unref (connection);
  g_socket_close (socket, &error);
  g_assert_no_error (error);
  g_object_unref (socket);
  return NULL;
}

static SkkServData *
create_server ()
{
  SkkServData *data;
  GSocket *server;
  GError *error = NULL;
  GSocketAddress *addr;
  GInetAddress *iaddr;

  data = g_slice_new (SkkServData);
  data->server = server = g_socket_new (G_SOCKET_FAMILY_IPV4,
					G_SOCKET_TYPE_STREAM,
					G_SOCKET_PROTOCOL_DEFAULT,
					&error);
  g_assert_no_error (error);

  g_socket_set_blocking (server, TRUE);

  iaddr = g_inet_address_new_loopback (G_SOCKET_FAMILY_IPV4);
  addr = g_inet_socket_address_new (iaddr, 0);
  g_object_unref (iaddr);

  g_socket_bind (server, addr, TRUE, &error);
  g_assert_no_error (error);
  g_object_unref (addr);

  g_socket_listen (server, &error);
  g_assert_no_error (error);

  data->thread = g_thread_create (skkserv_thread, data, TRUE, &error);
  g_assert_no_error (error);

  return data;
}

static void
skkserv (void)
{
  GError *error;
  SkkServData *data;
  GSocketAddress *addr;
  gchar *host;
  guint16 port;
  GInetAddress *iaddr;
  SkkSkkServ *dict;
  gint len;
  SkkCandidate **candidates;
  gboolean read_only;
  gchar **completion;
  SkkServTransaction transactions[] = {
    { "2", "0.0 " },
    { "1あい ", "1/愛/哀/相/挨/\n" },
    { "1あぱ ", "4" },
    { "4あ ", "1/あい/あいさつ/\n" },
    { "4あぱ ", "4" },
  };

  data = create_server ();
  data->transactions = transactions;
  data->n_transactions = G_N_ELEMENTS (transactions);

  error = NULL;
  addr = g_socket_get_local_address (data->server, &error);
  g_assert_no_error (error);

  port = g_inet_socket_address_get_port (G_INET_SOCKET_ADDRESS (addr));
  iaddr = g_inet_socket_address_get_address (G_INET_SOCKET_ADDRESS (addr));
  host = g_inet_address_to_string (iaddr);
  g_object_unref (addr);

  error = NULL;
  dict = skk_skk_serv_new (host, port, "UTF-8", &error);
  g_free (host);
  g_assert_no_error (error);

  g_assert (skk_dict_get_read_only (SKK_DICT (dict)));
  g_object_get (dict, "read-only", &read_only, NULL);
  g_assert (read_only);

  candidates = skk_dict_lookup (SKK_DICT (dict), "あい", FALSE, &len);
  g_assert_cmpint (len, ==, 4);
  while (--len >= 0) {
    g_object_unref (candidates[len]);
  }
  g_free (candidates);

  completion = skk_dict_complete (SKK_DICT (dict), "あ", &len);
  g_assert_cmpint (len, ==, 2);
  g_strfreev (completion);

  g_object_unref (dict);
  g_thread_join (data->thread);
  g_object_unref (data->server);
  g_slice_free (SkkServData, data);
}

int
main (int argc, char **argv)
{
  skk_init ();
  g_test_init (&argc, &argv, NULL);
  g_test_add_func ("/libskk/skkserv", skkserv);
  return g_test_run ();
}
