require 'spec_helper'

describe "Container Registry" do
  let(:project) { create(:empty_project) }
  let(:repository) { project.container_registry_repository }
  let(:tag_name) { 'latest' }
  let(:tags) { [tag_name] }
  let(:registry_settings) do
    {
      enabled: true
    }
  end

  before do
    login_as(:user)
    project.team << [@user, :developer]
    stub_container_registry(*tags)
    allow(Gitlab.config.registry).to receive_messages(registry_settings)
    allow(JWT::ContainerRegistryAuthenticationService).to receive(:full_access_token).and_return('token')
  end

  describe 'GET /:project/container_registry' do
    before do
      visit namespace_project_container_registry_index_path(project.namespace, project)
    end

    context 'when no tags' do
      let(:tags) { [] }

      it { expect(page).to have_content('No images in Container Registry for this project') }
    end

    context 'when there are tags' do
      it { expect(page).to have_content(tag_name)}
    end
  end

  describe 'DELETE /:project/container_registry/tag' do
    before do
      visit namespace_project_container_registry_index_path(project.namespace, project)
    end

    it do
      expect_any_instance_of(::ContainerRegistry::Tag).to receive(:delete).and_return(true)

      click_on 'Remove'
    end
  end
end
