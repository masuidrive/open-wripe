FactoryBot.define do
  factory :testdrive1, :class => User do
    username { 'testdrive1' }
    email { 'testdrive1@example.com' }
    icon_url { 'http://example.com/testdrive1.png' }
  end
  
  factory :testdrive2, :class => User do
    username { 'testdrive2' }
    email { 'testdrive2@example.com' }
    icon_url { 'http://example.com/testdrive2.png' }
  end
end
