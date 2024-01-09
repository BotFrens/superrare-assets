class JsonShare < BotAction
  include TwitterActivity

  def compose
    require_meta(%i[endpoint])
    text_template = meta[:text_template]
    body = coalesce_meta(:body, '')
    if meta[:random_min] && meta[:random_max]
      random_number = rand(meta[:random_min]..meta[:random_max])
      body = format(body, { random_number: random_number })
    end
    method = coalesce_meta(:method, 'get')
    json_response = flattened_json(fetch_endpoint_data(meta[:endpoint], method: method, body: body))
    template_data = clean_fields(json_response)
    image_url_template = meta[:image_url_template]
    image_caption_template = meta[:image_caption_template]
    discord_embed = meta[:discord_embed]

    post = {}
    post[:text] = format(text_template, template_data) unless discord_embed.present?

    post[:media] = formatted_media(image_url_template, template_data) if image_url_template
    post[:image_caption] = formatted_caption(image_caption_template, template_data) if image_caption_template
    post[:discord_embed] = formatted_embed(discord_embed, template_data) if discord_embed.present?
    post
  end
end
