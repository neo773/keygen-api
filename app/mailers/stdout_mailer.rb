# frozen_string_literal: true

class StdoutMailer < ApplicationMailer
  default from: 'Zeke at Keygen <zeke@keygen.sh>'

  def issue_zero(subscriber:)
    return if
      subscriber.stdout_unsubscribed_at?

    enc_email = encrypt(subscriber.email)
    return if
      enc_email.nil?

    unsub_link = stdout_unsubscribe_url(enc_email, protocol: 'https', host: 'stdout.keygen.sh')
    greeting   = if subscriber.first_name?
                    "Hey, #{subscriber.first_name}"
                  else
                    'Hey'
                  end

    mail(
      content_type: 'text/plain',
      to: subscriber.email,
      subject: 'November in review -- trying something different',
      body: <<~TXT
        #{greeting} -- long time no update! Zeke here, founder of Keygen.

        (You're receiving this email because you or your team signed up for a Keygen account. If you don't
        find this email useful, you can unsubscribe below.)

        I'm gonna be trying something new -- a periodic email update covering "what's new" in Keygen. It
        was recently brought to my attention that I don't do a good job of surfacing new updates to Keygen
        customers, so I hope this changes that. If you don't want to receive emails like this, you can
        opt-out anytime by following this link:

          #{unsub_link}

        --

        A lot has happened in 2021, so this zeroth issue of "Stdout" (what I'll be calling this) may be
        a little bit lengthier than future issues. There are a lot of other, smaller, changes that have
        happened, but for those you can check out Keygen's changelog.

        To kick things off, let's talk software distribution --

        ## Keygen Dist v2

        A few months back, we rolled out a brand new version of our distribution API. We made the decision
        to build a better version from the ground up -- one that is fully integrated into our flagship
        software licensing API. This has been a huge goal of mine, really, since I first wrote the Go
        prototype for the first distribution API.

        Some of the rad features for Dist v2:

          - You can add entitlement constraints to releases, ensuring that only users that possess a license
            with those entitlements can access the release. E.g. a popular use case is locking a license to
            a specific major version of a product until they purchase an upgrade. This can be accomplished
            using entitlement constraints, with a V1 and V2 entitlement, respectively.

          - You can set a product's "distribution strategy", allowing you to either distribute your product
            releases OPENly to anybody, no license required, or only to LICENSED users (the default). This
            really opens up doors for Keygen to support a wider variety of business models, such as freemium
            distribution as well as open source (like our CLI, which I'll touch on in a sec).

          - Since the new distribution API is fully integrated into our licensing API, scoping releases
            per-license and per-user is now possible. When authenticated as a licensee, they only see
            the product releases they have a license for.

        We've deprecated our older distribution API, dist.keygen.sh. It'll continue to be available, but we
        recommend using our new API for all new product development.

        The new API is now available at api.keygen.sh.

        Docs: https://keygen.sh/docs/api/releases/

        ## Go SDK

        With the launch of our new distribution API, I really wanted to start focusing on SDKs. We recently
        rolled out our first SDK, for Go. With it, you can add license validation, activation, and automatic
        upgrades to any Go application. It's super slick.

        We're currently working on other SDKs as well, for Node, Swift, and C#. Up next will be a macOS SDK,
        written in Swift. Let me know if you have any specific requests for an SDK!

        Source: https://github.com/keygen-sh/keygen-go
        Docs: https://keygen.sh/docs/api/auto-updates/#auto-updates-go

        Next up, let's talk command line --

        ## Keygen CLI

        We just recently rolled out the beta for our new Keygen CLI. You can use it to sign and publish new
        software releases to the new aforementioned distribution API. Keygen's CLI itself is published
        using the CLI, and it utilizes our Go SDK for automatic upgrades, all backed by Keygen's new
        distribution API (it's dogfooding all the way down!)

        The Keygen CLI is easy to integrate into your normal build and release workflow, complete with support
        for CI/CD environments. Securely sign releases using an Ed25519 private key, and verify upgrades
        using a public key. You can generate a key pair with the CLI's genkey command.

        To install the CLI and try it out, run this "quick install" script:

            curl -sSL https://get.keygen.sh/keygen/cli/install.sh | sh

        The install script will auto-detect your platform and install the approriate binary. You can, of
        course, install manually by visiting the docs, linked below.

        Source: https://github.com/keygen-sh/keygen-cli
        Docs: https://keygen.sh/docs/cli/

        ## Electron Builder

        We've teamed up with the electron-builder maintainers to craft a super slick integration, allowing
        you to easily provide automatic upgrades, served by the new distribution API, with only a few lines
        of code. (Publishing releases is just as easy -- electron-builder does all the work.)

            const { autoUpdater } = require('electron-updater')

            // Pass in an API token that belongs to the licensee (i.e. a user or
            // activation token)
            autoUpdater.addAuthHeader(`Bearer ${token}`)

            // Check for updates
            autoUpdater.checkForUpdatesAndNotify()

        I'm super stoked about this one. It's something I've been wanting to do since I first created Keygen,
        at a time where licensing APIs weren't even a thing. I hope this makes licensing and distributing
        an Electron app just a little bit easier!

        Source: https://github.com/electron-userland/electron-builder
        Docs: https://keygen.sh/docs/api/auto-updates/#auto-updates-electron

        --

        Well, that's it for this first issue of Stdout. Let me know if you have any feedback for me. We're
        going to make 2022 a great year -- complete with a brand new, much needed, UI overhaul (including
        a highly-requested *customer-facing* portal!)

        Thank you so much for your support!

        Until next time.

        --
        Zeke, Founder <https://keygen.sh>

        p.s. If you know anyone, we have a new affiliate program: https://keygen.sh/affiliates/ :)
      TXT
    )
  end

  def issue_one(subscriber:)
    return if
      subscriber.stdout_unsubscribed_at?

    enc_email = encrypt(subscriber.email)
    return if
      enc_email.nil?

    unsub_link = stdout_unsubscribe_url(enc_email, protocol: 'https', host: 'stdout.keygen.sh')
    greeting   = if subscriber.first_name?
                    "Hey, #{subscriber.first_name}"
                  else
                    'Hey'
                  end

    mail(
      content_type: 'text/plain',
      to: subscriber.email,
      subject: 'January in review -- announcing license key authentication!',
      body: <<~TXT
        #{greeting} -- Zeke here with another quick update.

        (You're receiving this email because you or your team signed up for a Keygen account. If you don't
        find this email useful, you can unsubscribe below.)

          #{unsub_link}

        --

        We heard you loud and clear! Activation tokens were not the most convenient authentication mechanism in the world. They had to be created after a license was created, which required multiple API requests, and figuring out which values to send to an end-user was kind of a headache. Should you send the license key? The activation token? Both? (Typically, the answer was both — which kind of sucked.)

        Starting today, you can configure your policies to have a license key authentication strategy. Doing so will allow you to authenticate with our API using a license key. Simply adjust your policy's authentication strategy to LICENSE, and start passing a license key into any API request's Authorization header using a new License scheme:

          Authorization: License C1B6DE-39A6E3-DE1529-8559A0-4AF593-V3

        It's that simple! No activation token required!

        Instead of figuring out which values to send to your end-users during fulfillment — all you have to do is send them a license key. No other values required! You can then perform any API request that you could do with an activation token, like activate a machine, download a release upgrade, or send a heartbeat ping.

        You can, of course, continue to use activation tokens! Nothing has changed there. And pretty soon, you'll be able to adjust permissions on a per-token basis. So activation tokens will still have a place — where more fine-grained access control is needed. But for the majority of use cases, switching to license key authentication will likely simplify your integration and fulfillment, as well as your software's end-user experience, which we think is a win-win.

        Note on backwards compatibility: for existing policies, and any new policies — nothing has changed. This is an opt-in feature only. Policies will default to using a TOKEN authentication strategy, which behaves exactly like it did before we introduced this new authentication scheme.

        If you'd like to opt-in, switch your policy's authentication strategy to LICENSE. (You can even accept both types of authentication, using MIXED, which should help during migration.)

        --

        Aside: we're looking for users for our new Zapier integration! Zapier needs us to have a handful of live users before we're able to publish our integration publicly. To try it out, use the invite link at the bottom of this page:

          https://keygen.sh/integrate/zapier/

        --

        Well, that's it for the second issue of Stdout (well, first... if we count from zero). Let me know if you have any feedback for me -- would love to hear it.

        There's a lot more cool stuff coming up that I'm excited to share.

        Until next time.

        --
        Zeke, Founder <https://keygen.sh>

        p.s. for more on API authentication, check out our updated docs: https://keygen.sh/docs/api/authentication/
      TXT
    )
  end

  private

  def encrypt(plaintext)
    crypt = ActiveSupport::MessageEncryptor.new(secret_key, serializer: JSON)
    enc   = crypt.encrypt_and_sign(plaintext)
                 .split('--')
                 .map { |s| Base64.urlsafe_encode64(Base64.strict_decode64(s), padding: false) }
                 .join('.')

    enc
  rescue => e
    Keygen.logger.error "[stdout.encrypt] Encrypt failed: err=#{e.message}"

    nil
  end

  def secret_key
    Rails.application.secrets.stdout_secret_key
  end
end
