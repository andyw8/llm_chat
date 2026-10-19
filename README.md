# Ruby LLM Chat

A Rails app for chatting with any model in the RubyLLM registry: streaming replies, tool calls, per-chat settings, and cost tracking.

It starts from the `ruby_llm:chat_ui` generator in [crmne/ruby_llm](https://github.com/crmne/ruby_llm):

```sh
bundle add ruby_llm
bin/rails generate ruby_llm:install
bin/rails generate ruby_llm:chat_ui
bin/rails db:migrate
```

Everything below is what this app adds on top of that.

## What's added

**A redesigned chat screen.** Conversations live in a sidebar next to the chat. Selecting one loads just the transcript, keeps the URL in step so back and forward work, and leaves the sidebar untouched. Streaming replies stay pinned to the latest message.

**Only models you can actually use.** The new-chat list offers models whose provider is configured, preselecting a sensible default and explaining what's missing when nothing is available. The Models screen shows each provider's models with context window, pricing, and availability, and can re-sync the registry.

**Per-chat settings.** Title, model, system prompt, reasoning effort, and temperature, edited from a sheet in the chat header. A system prompt is sent as configuration instead of joining the transcript, and switching models drops settings the new model doesn't support.

**Delete messages.** Any user or assistant message can be deleted after a confirmation; it disappears from the transcript (and from other open tabs) and is removed from the database.

**Cost and token tracking.** Each reply shows what it cost, and the settings sheet summarises the conversation's spend and token use. Providers that publish no pricing read as unknown rather than free.

**Built on Poetry.** [Poetry](https://github.com/roboruby/poetry) components and its form builder replace the generated markup, with one theme and no hand-written colours.

## Running it locally

Requires Ruby, PostgreSQL, and an API key for at least one provider.

```sh
bin/setup
bin/dev     # rails server + Tailwind watcher
```

Keys come from the environment or Rails credentials:

```sh
export OPENROUTER_API_KEY=...
export OPENAI_API_KEY=...
```

`/chats` is the root.

## Checks

```sh
bin/rails test
bin/rubocop
bin/rails poetry:check
```

CI runs Brakeman, `bundler-audit`, `importmap audit`, RuboCop, and the tests.

## Stack

Rails 8 · PostgreSQL · Solid Queue/Cache/Cable · Turbo + Stimulus · Tailwind via [Poetry](https://github.com/roboruby/poetry) · [ruby_llm](https://github.com/crmne/ruby_llm)
