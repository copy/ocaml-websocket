open Lwt.Infix

let port = 3000

let rec client_loop client =
  Websocket_lwt.Connected_client.recv client >>= fun frame ->
  Websocket_lwt.Connected_client.send client frame >>= fun () ->
  client_loop client

let handle client =
  Lwt_log_core.ign_notice_f "Got client\n";
  client_loop client

let on_exn e =
  Lwt_log.ign_notice_f "Got exception: %s\n" @@ Printexc.to_string e

let main () =
  let ctx = Conduit_lwt_unix.default_ctx in
  let mode = `TCP (`Port port) in
  Lwt.ignore_result (Websocket_lwt.establish_server ~ctx ~mode ~on_exn handle);
  Lwt_log_core.ign_notice_f "Waiting for clients ...\n";
  fst @@ Lwt.wait ()

let () =
  Lwt_main.run (main ())
