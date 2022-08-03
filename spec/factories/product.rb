# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::App.name }
    platforms {
      [
        Faker::Hacker.abbreviation,
        Faker::Hacker.abbreviation,
        Faker::Hacker.abbreviation
      ]
    }

    account { nil }

    after :build do |product, evaluator|
      product.account ||= evaluator.account.presence
    end

    trait :licensed do
      after :build do |product, evaluator|
        product.distribution_strategy = 'LICENSED'
      end
    end

    trait :open do
      after :build do |product, evaluator|
        product.distribution_strategy = 'OPEN'
      end
    end

    trait :closed do
      after :build do |product, evaluator|
        product.distribution_strategy = 'CLOSED'
      end
    end
  end
end
