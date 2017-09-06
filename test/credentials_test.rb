require_relative 'test_helper'
require 'date'

class CredentialsTest < Minitest::Test
  FIRST_NAME = 'first'
  LAST_NAME = 'last'

  def test_list_credentials
    VCR.use_cassette(:credentials) do
      unassigned_credential
      credentials = brivo_client.credentials
      assert credentials.is_a? Brivo::Collection

      credential = credentials.first
      assert credential.is_a? Brivo::Credential
      assert credential.id.is_a? Integer
      assert credential.reference_id.is_a? String
    end
  end

  def test_list_assigned_credentials
    VCR.use_cassette(:assigned_credentials) do
      credentials = brivo_client.credentials(status: :assigned)

      assert credentials.is_a? Brivo::Collection
    end
  end

  def test_credential_user
    VCR.use_cassette(:credential_user) do
      credential = assigned_credential

      assert credential.user.is_a? Brivo::User
    end
  end

  def test_list_unassigned_credentials
    VCR.use_cassette(:unassigned_credentials) do
      credentials = brivo_client.credentials(status: :unassigned)

      assert credentials.is_a? Brivo::Collection
    end
  end

  def test_delete_credential
    VCR.use_cassette(:delete_credential) do
      credential = unassigned_credential

      assert credential.delete
      assert_raises Brivo::Error::NotFound do
        brivo_client.credential(credential.id)
      end
    end
  end

  private

  def assigned_credential
    credential = unassigned_credential

    brivo_user.assign_credential(credential.id, Date.today, Date.today >> 1 )
    credential
  end

  def unassigned_credential
    id = '200'
    facility_code = '1'
    credentials = brivo_client.credentials.each do |credential|
      delete_credential = credential.field_values.any? do |field_value|
        field_value[:name] == 'acs.cards.format.card_number' && field_value[:value] == id
      end

      credential.delete if delete_credential
    end

    brivo_client.credential.create(id: id, facility_code: facility_code)
  end

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
