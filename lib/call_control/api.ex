defmodule CallControl.API do
  use Tesla

  defp api_key, do: Application.get_env(:call_control, :telnyx) |> Keyword.fetch!(:api_key)
  defp host, do: Application.get_env(:call_control, :host)

  plug Tesla.Middleware.BaseUrl, "https://api.telnyx.com/v2"
  plug Tesla.Middleware.Headers, [{"authorization", "Bearer " <> api_key()}]
  plug Tesla.Middleware.JSON

  def answer_call(id, client_state) do
    post("/calls/#{id}/actions/answer", %{client_state: client_state})
  end

  def reject_call(id) do
    post("/calls/#{id}/actions/reject", %{})
  end

  def hangup_call(id) do
    post("/calls/#{id}/actions/hangup", %{})
  end

  def speak_text(id, text) do
    data = %{
      payload: text,
      voice: "female",
      language: "en-US"
    }

    post("/calls/#{id}/actions/speak", data)
  end

  def play_audio(id, filename) do
    data = %{
      audio_url: host() <> "/" <> filename
    }

    post("/calls/#{id}/actions/playback_start", data)
  end
end
