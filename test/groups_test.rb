require_relative 'test_helper'

class GroupsTest < Minitest::Test
  NAME = 'group'
  
  def test_create_group
    VCR.use_cassette(:create_group) do
      group = brivo_group

      assert group.is_a? Brivo::Group
      assert_equal NAME, group.name
      assert group.id.is_a? Integer
    end
  end

  def test_find_group
    VCR.use_cassette(:find_group) do
      created_group = brivo_group
      group = brivo_client.group(created_group.id)

      assert group.is_a? Brivo::Group
      assert_equal NAME, group.name
      assert_equal created_group.id, group.id
    end
  end

  def test_delete_group
    VCR.use_cassette(:delete_group) do
      group = brivo_group
      assert group.delete

      assert_raises Brivo::NotFound do
        brivo_client.group(group.id)
      end
    end
  end

  def test_group_users
    VCR.use_cassette(:group_users) do
      group = brivo_group

      user = brivo_client.user.create(
        first_name: 'first',
        last_name: 'last'
      )

      assert group.assign_user(user.id)
      group_users = group.users

      assert group_users.is_a? Brivo::Collection
      assert group_users.first.is_a? Brivo::User
      assert_equal user.id, group_users.first.id

      user_groups = user.groups

      assert user_groups.is_a? Brivo::Collection
      assert user_groups.first.is_a? Brivo::Group
      assert_equal group.id, user_groups.first.id

      assert group.remove_user(user.id)
      assert_equal 0, group.users.count
    end
  end

  private

  def brivo_group
    brivo_client.group.create(name: NAME)
  end
end
