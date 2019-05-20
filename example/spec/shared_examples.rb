# frozen_string_literal: true

shared_examples 'shared examples' do
  context 'in a shared example' do
    it 'when succeeds' do
      expect(true).to be(true)
    end

    it 'when also fails' do
      expect(false).to be(true)
    end
  end
end
