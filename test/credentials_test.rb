require 'test_helper'

class CredentialsTest < Minitest::Test
  # TODO: Add ability to create credentials because at the moment these tests
  #       are dependent on there being credentials in Brivo or the cassette yml
  #       files existing
  def test_list_credentials
    VCR.use_cassette(:credentials) do
      credentials = brivo_client.credentials
      assert credentials.is_a? Brivo::Collection

      credential = credentials.first
      assert credential.is_a? Brivo::Credential
      assert credential.id.is_a? Integer
      assert credential.reference_id.is_a? Integer
    end
  end

  def test_list_assigned_credentials
    VCR.use_cassette(:assigned_credentials) do
      credentials = brivo_client.credentials(status: :assigned)

      assert credentials.is_a? Brivo::Collection
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
      credential = brivo_client.credentials(status: :unassigned).first

      assert credential.delete
      assert_raises Brivo::NotFound do
        brivo_client.credential(credential.id)
      end
    end
  end
end
