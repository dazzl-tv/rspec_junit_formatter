# frozen_string_literal: true

shared_examples 'shared examples' do
  context 'with shared example' do
    let(:base_success) { true }
    let(:base_fail) { false }
    let(:output) { true }

    it 'when succeeds' do
      expect(base_success).to be(output)
    end

    it 'when also fails' do
      expect(base_fail).to be(output)
    end
  end
end
