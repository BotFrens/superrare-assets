class SuperrarePoolHighlight < JsonShare
  include TwitterActivity
  TRENDING_POOLS_BODY = '{"query":"query TrendingPools($pagination: PaginationInput!) {\n  trendingPools(pagination: $pagination) {\n    pool {\n      poolAddress\n      createdAt\n      target {\n        address\n        owner {\n          primaryAddress\n          primaryProfile {\n            ens {\n              ensName\n              ensAvatarUri\n            }\n            sr {\n              srName\n              srAvatarUri\n            }\n             lens {\n              lensName\n              lensAvatarUri\n            }\n          }\n          addresses {\n            address\n            profile {\n              ens {\n                ensName\n                ensAvatarUri\n              }\n            }\n          }\n        }\n        isPrimary\n        profile {\n          sr {\n            srName\n            srAvatarUri\n          }\n        }\n      }\n      creator {\n        address\n        owner {\n          primaryAddress\n          primaryProfile {\n            sr {\n              srName\n              srAvatarUri\n            }\n          }\n        }\n      }\n      accumulatorAddress\n    }\n  }\n}","variables":{"pagination":{"offset":%{random_number},"limit":1,"sortBy":"poolAddress","order":"DESC"}}}'
  STATS_BODY = '{"query":"query PoolStatsByPoolAddresses($poolAddresses: [String!]!) {\n  poolStatsByPoolAddresses(poolAddresses: $poolAddresses) {\n    pool {\n      poolAddress\n      createdAt\n     \n      creator {\n        address\n        owner {\n          primaryAddress\n          primaryProfile {\n            sr {\n              srName\n              srAvatarUri\n            }\n          }\n        }\n        profile {\n          sr {\n            srName\n            srAvatarUri\n          }\n        }\n      }\n      accumulatorAddress\n    }\n    totalStaked\n    totalRewards\n    stakerCount\n    unswappedEth\n  }\n}","variables":{"poolAddresses":["%{pool_address}"]}}'

  def compose
    body = format(TRENDING_POOLS_BODY, { random_number: rand(0..100) })
    json_response = flattened_json(fetch_endpoint_data(
                                     'https://api-rare-xyz-v1-prod-6fuihnetla-ue.a.run.app/v1/graphql', method: 'post', body: body
                                   ))
    pool_data = clean_fields(json_response)
    pool_address = pool_data[:data_trendingPools_0_pool_poolAddress_raw]
    stats_body = format(STATS_BODY, { pool_address: pool_address })
    json_response = flattened_json(fetch_endpoint_data(
                                     'https://api-rare-xyz-v1-prod-6fuihnetla-ue.a.run.app/v1/graphql', method: 'post', body: stats_body
                                   ))
    stats_data = clean_fields(json_response)
    template_data = pool_data.merge(stats_data)
    image_url_template = meta[:image_url_template]
    image_caption_template = meta[:image_caption_template]
    discord_embed = meta[:discord_embed]
    text_template = meta[:text_template]

    post = {}
    post[:text] = format(text_template, template_data) unless discord_embed.present?

    post[:media] = formatted_media(image_url_template, template_data) if image_url_template
    post[:image_caption] = formatted_caption(image_caption_template, template_data) if image_caption_template
    post[:discord_embed] = formatted_embed(discord_embed, template_data) if discord_embed.present?

    post
  end
end
