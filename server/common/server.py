import logging
import signal
import socket
import sys


class Server:
    def __init__(self, port, listen_backlog):
        # Initialize server socket
        self._server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._server_socket.bind(('', port))
        self._server_socket.listen(listen_backlog)
        self._current_client_socket = None
        self._interrupted = False
        signal.signal(signal.SIGTERM, self.__handle_interruption)

    def run(self):
        """
        Dummy Server loop

        Server that accept a new connections and establishes a
        communication with a client. After client with communucation
        finishes, servers starts to accept new connections again
        """

        while True:
            client_sock = self.__accept_new_connection()
            if client_sock is not None:
                self.__handle_client_connection(client_sock)
        logging.debug("Main loop done!")

    def __handle_client_connection(self, client_sock):
        """
        Read message from a specific client socket and closes the socket

        If a problem arises in the communication with the client, the
        client socket will also be closed
        """
        try:
            msg = client_sock.recv(1024).rstrip().decode('utf-8')
            logging.info(
                'Message received from connection {}. Msg: {}'
                .format(client_sock.getpeername(), msg))
            client_sock.send("Your Message has been received: {}\n".format(msg).encode('utf-8'))
        except OSError:
            logging.info("Error while reading socket {}".format(client_sock))
        finally:
            self._current_client_socket = None
            client_sock.close()
            logging.debug("Closed client socket, current: {}".format(self._current_client_socket))

    def __accept_new_connection(self):
        """
        Accept new connections

        Function blocks until a connection to a client is made.
        Then connection created is printed and returned
        """

        try:
            if not self._interrupted:
                # Connection arrived
                logging.info("Proceed to accept new connections")
                client_socket, addr = self._server_socket.accept()
                logging.info('Got connection from {}'.format(addr))
                self._current_client_socket = client_socket
                logging.debug('Current client socket: {}'.format(client_socket))
                return client_socket
        except OSError as e:
            if not self._interrupted:
                logging.error("Error accepting new connection: {}".format(e))
            return None  # An error occurred because of trying to read from a socket closed by an interruption

    def __handle_interruption(self, *args):
        """
        Function executed when SIGTERM signal is received

        It closes the server socket & the current client socket if it exists
        """
        logging.info("Handling SIGTERM interruption")
        self._interrupted = True
        sigterm_response_code = 143
        try:
            try:
                logging.debug("Attempting to close server socket")
                self._server_socket.close()
                logging.debug("Successfully closed server socket")
            except Exception as e:
                logging.error("Error closing server socket: {}".format(e))

            if self._current_client_socket is not None:
                try:
                    logging.debug("Attempting to close current client connection")
                    self._current_client_socket.close()
                    logging.debug("Successfully closed current client connection")
                except Exception as e:
                    logging.error("Error closing current client socket: {}".format(e))
        finally:
            sys.exit(sigterm_response_code)
