class AddRocketchatIntegration < ActiveRecord::Migration[4.2]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    settings_update = [
      {
        'name'        => '6300_rocket_webhook',
        'title'       => 'Defines transaction backend.',
        'description' => 'Defines the transaction backend which posts messages to Rocket Chat (https://rocket.chat).',
      },
      {
        'name'        => 'rocket_integration',
        'title'       => nil,
        'description' => 'Defines if Rocket Chat (https://rocket.chat) is enabled or not.',
      },
      {
        'name'        => 'rocket_config',
        'title'       => nil,
        'description' => 'Defines the slack config.',
      },
    ]

    settings_update.each do |setting|
      fetched_setting = Setting.find_by(name: setting['name'] )
      next if !fetched_setting

      if setting['title']
        fetched_setting.title = setting['title']
      end

      if setting['description']
        fetched_setting.description = setting['description']
      end

      fetched_setting.save!
    end

    Translation.sync


  end

end 
