# frozen_string_literal: true

class Permission < ApplicationRecord
  has_many :role_permissions
  has_many :token_permissions
  has_many :group_permissions

  # The action name of the wildcard permission.
  WILDCARD_PERMISSION = '*'.freeze

  # Available permissions.
  ALL_PERMISSIONS = %w[
    account.analytics.read
    account.billing.read
    account.billing.update
    account.plan.read
    account.plan.update
    account.read
    account.subscription.read
    account.subscription.update
    account.update

    arch.read

    artifact.create
    artifact.delete
    artifact.download
    artifact.read
    artifact.update
    artifact.upload

    channel.read

    entitlement.create
    entitlement.delete
    entitlement.read
    entitlement.update

    event-log.read

    group.create
    group.delete
    group.read
    group.update
    group.licenses.read
    group.machines.read
    group.owners.attach
    group.owners.detach
    group.owners.read
    group.users.read

    key.create
    key.delete
    key.policy.read
    key.product.read
    key.read
    key.update

    license.check-in
    license.check-out
    license.create
    license.delete
    license.entitlements.attach
    license.entitlements.detach
    license.entitlements.read
    license.group.read
    license.group.update
    license.machines.read
    license.policy.read
    license.policy.update
    license.product.read
    license.read
    license.reinstate
    license.renew
    license.revoke
    license.suspend
    license.tokens.generate
    license.tokens.read
    license.update
    license.usage.decrement
    license.usage.increment
    license.usage.reset
    license.user.update
    license.user.read
    license.validate

    machine.check-out
    machine.create
    machine.delete
    machine.group.read
    machine.group.update
    machine.heartbeat.ping
    machine.heartbeat.reset
    machine.license.read
    machine.processes.read
    machine.product.read
    machine.proofs.generate
    machine.update
    machine.user.read
    machine.read

    metric.read

    policy.create
    policy.delete
    policy.entitlements.attach
    policy.entitlements.detach
    policy.entitlements.read
    policy.pool.read
    policy.pool.pop
    policy.read
    policy.update

    process.create
    process.delete
    process.heartbeat.ping
    process.read
    process.update

    product.artifacts.read
    product.releases.read
    product.arches.read
    product.channels.read
    product.platforms.read
    product.create
    product.delete
    product.read
    product.tokens.generate
    product.tokens.read
    product.update

    platform.read

    release.constraints.attach
    release.constraints.detach
    release.constraints.read
    release.entitlements.read
    release.create
    release.delete
    release.publish
    release.read
    release.update
    release.upgrade
    release.upload
    release.yank

    request-log.read

    second-factor.create
    second-factor.delete
    second-factor.read
    second-factor.update

    token.generate
    token.regenerate
    token.read
    token.revoke

    user.ban
    user.create
    user.delete
    user.group.update
    user.invite
    user.password.update
    user.password.reset
    user.read
    user.tokens.generate
    user.tokens.read
    user.unban
    user.update

    webhook-endpoint.create
    webhook-endpoint.delete
    webhook-endpoint.read
    webhook-endpoint.update

    webhook-event.delete
    webhook-event.read
    webhook-event.retry
  ].freeze

  # Available admin permissions.
  ADMIN_PERMISSIONS = ALL_PERMISSIONS.dup
                                     .freeze

  # Available readonly permissions.
  READ_ONLY_PERMISSIONS =%w[
    account.analytics.read
    account.billing.read
    account.plan.read
    account.read
    account.subscription.read

    arch.read

    artifact.download
    artifact.read

    channel.read

    entitlement.read

    event-log.read

    group.read
    group.licenses.read
    group.machines.read
    group.owners.read
    group.users.read

    key.read
    key.policy.read
    key.product.read

    license.entitlements.read
    license.group.read
    license.machines.read
    license.policy.read
    license.product.read
    license.read
    license.tokens.read
    license.user.read

    machine.group.read
    machine.license.read
    machine.processes.read
    machine.product.read
    machine.read
    machine.user.read

    metric.read

    policy.entitlements.read
    policy.read

    process.read

    product.artifacts.read
    product.releases.read
    product.arches.read
    product.channels.read
    product.platforms.read
    product.read
    product.tokens.read

    platform.read

    release.constraints.read
    release.entitlements.read
    release.read
    release.upgrade

    request-log.read

    second-factor.create
    second-factor.delete
    second-factor.read
    second-factor.update

    token.generate
    token.read

    user.password.update
    user.password.reset
    user.read
    user.tokens.read

    webhook-endpoint.read

    webhook-event.read
  ]

  # Available product permissions.
  PRODUCT_PERMISSIONS = %w[
    account.read

    arch.read

    artifact.create
    artifact.delete
    artifact.download
    artifact.read
    artifact.update
    artifact.upload

    channel.read

    entitlement.read

    group.create
    group.delete
    group.read
    group.update
    group.licenses.read
    group.machines.read
    group.owners.attach
    group.owners.detach
    group.owners.read
    group.users.read

    key.create
    key.delete
    key.policy.read
    key.product.read
    key.read
    key.update

    license.check-in
    license.check-out
    license.create
    license.delete
    license.entitlements.attach
    license.entitlements.detach
    license.entitlements.read
    license.group.read
    license.group.update
    license.machines.read
    license.policy.read
    license.policy.update
    license.product.read
    license.read
    license.reinstate
    license.renew
    license.revoke
    license.suspend
    license.tokens.generate
    license.tokens.read
    license.update
    license.usage.decrement
    license.usage.increment
    license.usage.reset
    license.user.update
    license.user.read
    license.validate

    machine.check-out
    machine.create
    machine.delete
    machine.group.read
    machine.group.update
    machine.heartbeat.ping
    machine.heartbeat.reset
    machine.license.read
    machine.processes.read
    machine.product.read
    machine.proofs.generate
    machine.update
    machine.user.read
    machine.read

    policy.create
    policy.delete
    policy.entitlements.attach
    policy.entitlements.detach
    policy.entitlements.read
    policy.pool.read
    policy.pool.pop
    policy.read
    policy.update

    process.create
    process.delete
    process.heartbeat.ping
    process.read
    process.update

    product.artifacts.read
    product.releases.read
    product.arches.read
    product.channels.read
    product.platforms.read
    product.read
    product.update
    product.tokens.read

    platform.read

    release.constraints.attach
    release.constraints.detach
    release.constraints.read
    release.entitlements.read
    release.create
    release.delete
    release.publish
    release.read
    release.update
    release.upgrade
    release.upload
    release.yank

    token.generate
    token.regenerate
    token.revoke
    token.read

    user.ban
    user.create
    user.group.update
    user.read
    user.tokens.generate
    user.tokens.read
    user.unban
    user.update

    webhook-event.read
  ].freeze

  # Available user permissions.
  USER_PERMISSIONS = %w[
    account.read

    arch.read

    artifact.download
    artifact.read

    channel.read

    entitlement.read

    group.read
    group.licenses.read
    group.machines.read
    group.owners.read
    group.users.read

    license.check-in
    license.check-out
    license.create
    license.entitlements.read
    license.group.read
    license.delete
    license.machines.read
    license.policy.read
    license.policy.update
    license.product.read
    license.read
    license.renew
    license.revoke
    license.usage.increment
    license.user.read
    license.validate

    machine.check-out
    machine.create
    machine.delete
    machine.group.read
    machine.heartbeat.ping
    machine.license.read
    machine.processes.read
    machine.product.read
    machine.proofs.generate
    machine.read
    machine.update
    machine.user.read

    policy.read

    process.create
    process.delete
    process.heartbeat.ping
    process.read
    process.update

    product.artifacts.read
    product.releases.read
    product.arches.read
    product.channels.read
    product.platforms.read
    product.read

    platform.read

    release.constraints.read
    release.read
    release.upgrade

    second-factor.create
    second-factor.delete
    second-factor.read
    second-factor.update

    token.generate
    token.regenerate
    token.revoke
    token.read

    user.password.update
    user.password.reset
    user.read
    user.update
    user.tokens.read
  ].freeze

  # Available license permissions.
  LICENSE_PERMISSIONS = %w[
    account.read

    arch.read

    artifact.download
    artifact.read

    channel.read

    entitlement.read

    group.owners.read
    group.read

    license.check-in
    license.check-out
    license.entitlements.read
    license.group.read
    license.machines.read
    license.policy.read
    license.product.read
    license.read
    license.usage.increment
    license.user.read
    license.validate

    machine.check-out
    machine.create
    machine.delete
    machine.group.read
    machine.heartbeat.ping
    machine.license.read
    machine.processes.read
    machine.product.read
    machine.proofs.generate
    machine.read
    machine.update
    machine.user.read

    policy.read

    process.create
    process.delete
    process.heartbeat.ping
    process.read
    process.update

    product.artifacts.read
    product.releases.read
    product.arches.read
    product.channels.read
    product.platforms.read
    product.read

    platform.read

    release.constraints.read
    release.read
    release.upgrade

    token.regenerate
    token.revoke
    token.read

    user.read
  ].freeze

  # wildcard returns the wildcard permission record.
  def self.wildcard = where(action: WILDCARD_PERMISSION).take

  # wildcard_id returns the wildcard permission ID.
  def self.wildcard_id = where(action: WILDCARD_PERMISSION).pick(:id)

  # wildcard? checks if any of the given IDs are the wildcard permission.
  def self.wildcard?(*identifiers)
    return true if
      identifiers.include?(WILDCARD_PERMISSION)

    exists?(id: identifiers, action: WILDCARD_PERMISSION)
  end
end
