FactoryBot.define do
  factory :testpage, :class => Page do
    user { create(:testdrive1) }
    title { 'TITLE' }
    body { 'BODY' }
  end
end