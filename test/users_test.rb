require_relative 'test_helper'
require 'date'

class UsersTest < Minitest::Test
  FIRST_NAME = 'first'
  LAST_NAME = 'last'

  def test_create_user
    VCR.use_cassette(:create_user) do
      user = brivo_user

      assert user.is_a? Brivo::User
      assert_equal FIRST_NAME, user.first_name
      assert_equal LAST_NAME, user.last_name
      assert_equal false, user.suspended
      assert user.id.is_a? Integer
    end
  end

  def test_find_user
    VCR.use_cassette(:find_user) do
      created_user = brivo_user
      user = brivo_client.user(created_user.id)

      assert user.is_a? Brivo::User
      assert_equal FIRST_NAME, user.first_name
      assert_equal LAST_NAME, user.last_name
      assert_equal false, user.suspended
      assert_equal created_user.id, user.id
    end
  end

  def test_find_user_external_id
    VCR.use_cassette(:find_user_external_id) do
      created_user = brivo_user
      user = brivo_client.user(created_user.id)

      assert user.is_a? Brivo::User
      assert_equal FIRST_NAME, user.first_name
      assert_equal LAST_NAME, user.last_name
      assert_equal false, user.suspended
      assert_equal created_user.id, user.id
    end
  end

  def test_delete_user
    VCR.use_cassette(:delete_user) do
      user = brivo_user
      assert user.delete

      assert_raises Brivo::Error::NotFound do
        brivo_client.user(user.id)
      end
    end
  end

  def test_list_users
    VCR.use_cassette(:list_users) do
      brivo_user

      users = brivo_client.users
      assert users.count > 0
      assert users.is_a? Brivo::Collection
      assert users.first.is_a? Brivo::User
    end
  end

  def test_user_credentials
    VCR.use_cassette(:user_credentials) do
      user = brivo_user

      credential = brivo_client.credentials(status: :unassigned).first

      start_date = Date.today
      end_date = start_date >> 1

      assert user.assign_credential credential.id, start_date, end_date
      assert_equal credential.id, user.credentials.first.id

      assert user.remove_credential credential.id
      assert_equal 0, user.credentials.count
    end
  end

  private

  def brivo_user
    begin
      user = brivo_client.user(external_id: 1)
      user.delete
    rescue Brivo::Error::NotFound
    end

    brivo_client.user.create(
      first_name: FIRST_NAME,
      last_name: LAST_NAME,
      external_id: 1
    )
  end
end
