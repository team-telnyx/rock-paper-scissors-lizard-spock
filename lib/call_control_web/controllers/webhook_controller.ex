defmodule CallControlWeb.WebhookController do
  use CallControlWeb, :controller
  require Logger

  def multiplayer(conn, payload) do
    IO.inspect(payload)
    CallControl.MultiPlayer.handle(payload)
    render(conn, "response.json")
  end

  def singleplayer(conn, payload) do
    IO.inspect(payload)
    xml_response = CallControl.SinglePlayer.handle(payload)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, xml_response)
  end
end
