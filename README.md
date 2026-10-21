# LLM Chat

A Rails app for chatting with LLM models. Powered by [crmne/ruby_llm](https://github.com/crmne/ruby_llm). Simlar to [Librechat](https://www.librechat.ai).

Ruby LLM provides a basic Rails generator build built a chat UI. This builds on top of that.

## What's added

* **A redesigned chat screen.** Conversations live in a sidebar next to the chat.
* **Only models you can actually use.** The new-chat list offers models whose provider is configured.
* **Per-chat settings.** Title, model, system prompt, reasoning effort, and temperature.
* **Delete messages.** Any user or assistant message can be deleted.
* **Cost and token tracking.** Each reply shows what it cost, and the settings sheet summarises the conversation's spend and token use.
* **Built on Poetry.** [Poetry](https://github.com/roboruby/poetry) components.

## Running it locally

Requires Ruby, PostgreSQL, and an API key for at least one provider.

```sh
bin/setup
bin/dev
```

Keys come from the environment or Rails credentials:

```sh
export OPENROUTER_API_KEY=...
export OPENAI_API_KEY=...
```
