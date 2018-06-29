
require 'integration_test_helper'
require 'rocket'

class SlackTest < ActiveSupport::TestCase

  # needed to check correct behavior
  rocket_group = Group.create_if_not_exists(
    name: 'Rocket',
    updated_by_id: 1,
    created_by_id: 1
  )

  # check
  test 'base' do

    if !ENV['ROCKET_CI_CHANNEL']
      raise "ERROR: Need ROCKET_CI_CHANNEL - hint ROCKET_CI_CHANNEL='test'"
    end
    if !ENV['ROCKET_CI_WEBHOOK']
      raise "ERROR: Need ROCKET_CI_WEBHOOK - hint ROCKET_CI_WEBHOOK='https://demo.rocket.chat/...'"
    end

    channel = ENV['ROCKET_CI_CHANNEL']
    webhook = ENV['ROCKET_CI_WEBHOOK']

    # set system mode to done / to activate
    Setting.set('system_init_done', true)
    Setting.set('rocket_integration', true)

    items = [
      {
        group_ids: [rocket_group.id],
        types: %w[create update reminder_reached],
        webhook: webhook,
        channel: channel,
        username: 'zammad bot',
        expand: false,
      }
    ]
    Setting.set('rocket_config', { items: items })

    # case 1
    customer = User.find(2)
    hash     = hash_gen
    text     = "#{rand_word}... #{hash}"

    default_group = Group.first
    ticket1 = Ticket.create(
      title:         text,
      customer_id:   customer.id,
      group_id:      default_group.id,
      state:         Ticket::State.find_by(name: 'new'),
      priority:      Ticket::Priority.find_by(name: '2 normal'),
      updated_by_id: 1,
      created_by_id: 1,
    )
    article1 = Ticket::Article.create(
      ticket_id:     ticket1.id,
      body:          text,
      type:          Ticket::Article::Type.find_by(name: 'note'),
      sender:        Ticket::Article::Sender.find_by(name: 'Customer'),
      internal:      false,
      updated_by_id: 1,
      created_by_id: 1,
    )

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(0, rocket_check(channel, hash))

    ticket1.state = Ticket::State.find_by(name: 'open')
    ticket1.save

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(0, slack_check(channel, hash))

    # case 2
    hash = hash_gen
    text = "#{rand_word}... #{hash}"

    ticket2 = Ticket.create(
      title:         text,
      customer_id:   customer.id,
      group_id:      rocket_group.id,
      state:         Ticket::State.find_by(name: 'new'),
      priority:      Ticket::Priority.find_by(name: '2 normal'),
      updated_by_id: 1,
      created_by_id: 1,
    )
    article2 = Ticket::Article.create(
      ticket_id:     ticket2.id,
      body:          text,
      type:          Ticket::Article::Type.find_by(name: 'note'),
      sender:        Ticket::Article::Sender.find_by(name: 'Customer'),
      internal:      false,
      updated_by_id: 1,
      created_by_id: 1,
    )

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(1, rocket_check(channel, hash))

    hash = hash_gen
    text = "#{rand_word}... #{hash}"

    ticket2.title = text
    ticket2.save

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(1, rocket_check(channel, hash))

    ticket2.state = Ticket::State.find_by(name: 'pending reminder')
    ticket2.pending_time = Time.zone.now - 2.days
    ticket2.save

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(2, rocket_check(channel, hash))

    Ticket.process_pending

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(3, rocket_check(channel, hash))

    Ticket.process_pending

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(3, rocket_check(channel, hash))

    items = [
      {
        group_ids: rocket_group.id.to_s,
        types: 'create',
        webhook: webhook,
        channel: channel,
        username: 'zammad bot',
        expand: false,
      }
    ]
    Setting.set('rocket_config', { items: items })

    # case 3
    customer = User.find(2)
    hash     = hash_gen
    text     = "#{rand_word}... #{hash}"

    default_group = Group.first
    ticket3 = Ticket.create(
      title:         text,
      customer_id:   customer.id,
      group_id:      default_group.id,
      state:         Ticket::State.find_by(name: 'new'),
      priority:      Ticket::Priority.find_by(name: '2 normal'),
      updated_by_id: 1,
      created_by_id: 1,
    )
    article3 = Ticket::Article.create(
      ticket_id:     ticket3.id,
      body:          text,
      type:          Ticket::Article::Type.find_by(name: 'note'),
      sender:        Ticket::Article::Sender.find_by(name: 'Customer'),
      internal:      false,
      updated_by_id: 1,
      created_by_id: 1,
    )

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(0, rocket_check(channel, hash))

    ticket3.state = Ticket::State.find_by(name: 'open')
    ticket3.save

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(0, rocket_check(channel, hash))

    # case 4
    hash = hash_gen
    text = "#{rand_word}... #{hash}"

    ticket4 = Ticket.create(
      title:         text,
      customer_id:   customer.id,
      group_id:      rocket_group.id,
      state:         Ticket::State.find_by(name: 'new'),
      priority:      Ticket::Priority.find_by(name: '2 normal'),
      updated_by_id: 1,
      created_by_id: 1,
    )
    article4 = Ticket::Article.create(
      ticket_id:     ticket4.id,
      body:          text,
      type:          Ticket::Article::Type.find_by(name: 'note'),
      sender:        Ticket::Article::Sender.find_by(name: 'Customer'),
      internal:      false,
      updated_by_id: 1,
      created_by_id: 1,
    )

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(1, rocket_check(channel, hash))

    hash = hash_gen
    text = "#{rand_word}... #{hash}"

    ticket4.title = text
    ticket4.save

    Observer::Transaction.commit
    Scheduler.worker(true)

    # check if message exists
    assert_equal(0, rocket_check(channel, hash))

  end

  def hash_gen
    (0...10).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def rand_word
    words = [
      'dog',
      'cat',
      'house',
      'home',
      'yesterday',
      'tomorrow',
      'new york',
      'berlin',
      'coffee script',
      'java script',
      'bob smith',
      'be open',
      'really nice',
      'stay tuned',
      'be a good boy',
      'invent new things',
    ]
    words[rand(words.length)]
  end

end
