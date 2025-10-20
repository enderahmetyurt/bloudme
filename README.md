# Bloudme

Follow your favourite web sites, and read in minimal design.

A modern RSS feed reader built with Ruby on Rails, designed for a clean and distraction-free reading experience.

## ✨ Features

- 📖 Clean, minimal reading interface
- 🔄 Automatic feed updates via background jobs
- 🔖 Bookmark articles for later reading
- 🎨 Modern, responsive design with Tailwind CSS
- ⚡ Fast, SPA-like experience with Hotwire/Turbo
- 👤 User authentication and personalized feeds
- 📧 Email confirmations and notifications
- 💳 Subscription management with LemonSqueezy integration

## 🚀 Tech Stack

- **Backend**: Ruby on Rails (Edge)
- **Frontend**: Hotwire/Turbo, Stimulus, Tailwind CSS
- **Database**: PostgreSQL
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Real-time**: Solid Cable
- **Testing**: MiniTest
- **Deployment**: Render.com
- **Monitoring**: Sentry

## 📋 Prerequisites

- Ruby 3.2+
- Node.js 18+
- PostgreSQL 14+

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/enderahmetyurt/bloudme.git
   cd bloudme
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Setup credentials**
   ```bash
   # This project uses Rails encrypted credentials instead of .env files
   # The .env.example file is provided for reference only
   # Configure your credentials using:
   rails credentials:edit --environment=development
   ```

4. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed # See user password
   ```

5. **Build assets**
   ```bash
   rails assets:precompile
   ```

6. **Start the development server**
   ```bash
   bin/dev
   ```

Visit `http://localhost:3000` in your browser.

## 🔧 Development

### Running tests
```bash
rails test
rails test:system
```

### Code quality
```bash
bundle exec rubocop
bundle exec brakeman
```

### Background jobs
Background jobs are handled by Solid Queue. In development, they run automatically.

### Adding feeds
Feeds can be added through the web interface or programmatically:

```ruby
feed = Feed.create!(
  name: "Example Blog",
  feed_url: "https://example.com/feed.xml",
  user: current_user
)
```

## 📡 API

### Authentication
The application uses session-based authentication. API endpoints require a valid session.

### Endpoints

- `GET /feeds` - List user's feeds
- `POST /feeds` - Create a new feed
- `GET /articles` - List articles from subscribed feeds
- `POST /bookmarks` - Bookmark an article
- `DELETE /bookmarks/:id` - Remove bookmark

## 🐳 Docker Development

```bash
docker-compose up -d
```

## 🚀 Production Deployment

The application is deployed on Render.com with automatic deployments from the main branch.

## 🔐 Configuration

This project uses **Rails encrypted credentials** instead of `.env` files for better security. The `.env.example` file is provided only as a reference for the configuration keys needed.

### Managing Credentials

```bash
# Edit development credentials
rails credentials:edit --environment=development
```

### Required Configuration Keys

See `.env.example` for reference. Your encrypted credentials should include:

- `database_url` - PostgreSQL connection string
- `sentry_dsn` - Error tracking (optional)
- `resend_api_key` - Email service (optional)
- `lemonsqueezy_api_key` - Payment processing (optional)
- `lemonsqueezy_store_id` - LemonSqueezy store ID (optional)
- `lemonsqueezy_variant_id` - LemonSqueezy variant ID (optional)
- `secret_key_base` - Rails secret key

### Why Credentials Instead of .env?

- **Security**: Credentials are encrypted and committed to the repository
- **Environment-specific**: Different credentials for development, test, and production
- **Team collaboration**: Secure sharing of configuration across team members
- **Deployment**: No need to manage separate environment variable files

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛡️ Security

If you discover a security vulnerability, please see [SECURITY.md](SECURITY.md) for reporting instructions.
