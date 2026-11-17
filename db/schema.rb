# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_17_144846) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "ruby_llm_model_id", null: false
    t.boolean "cancelled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "system_prompt"
    t.float "sampling_temperature"
    t.string "reasoning_effort"
    t.string "custom_title"
    t.string "claim_token"
    t.datetime "claimed_until"
    t.index ["claimed_until"], name: "index_chats_on_claimed_until", where: "(claim_token IS NOT NULL)"
    t.index ["ruby_llm_model_id"], name: "index_chats_on_ruby_llm_model_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.string "role", null: false
    t.text "content"
    t.boolean "cache_until_here", default: false, null: false
    t.string "cache_ttl"
    t.text "thinking_text"
    t.text "thinking_signature"
    t.jsonb "citations"
    t.jsonb "server_tool_calls"
    t.jsonb "raw_content"
    t.jsonb "raw_reasoning"
    t.string "finish_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phase"
    t.text "continuation"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "ruby_llm_batches", force: :cascade do |t|
    t.string "provider_batch_id", null: false
    t.string "provider", null: false
    t.string "status", null: false
    t.string "raw_status"
    t.boolean "completed", default: false, null: false
    t.string "chat_type"
    t.string "batch_protocol"
    t.jsonb "chat_ids", default: []
    t.jsonb "request_counts"
    t.jsonb "reported_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "provider_batch_id"], name: "index_ruby_llm_batches_on_provider_and_provider_batch_id", unique: true
    t.index ["status"], name: "index_ruby_llm_batches_on_status"
  end

  create_table "ruby_llm_chat_files", force: :cascade do |t|
    t.string "chat_type", null: false
    t.bigint "chat_id", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "path", null: false
    t.string "content_type"
    t.bigint "byte_size"
    t.string "digest"
    t.text "text"
    t.string "read_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_type", "chat_id", "path"], name: "index_ruby_llm_chat_files_on_chat_type_and_chat_id_and_path"
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_chat_files_on_owner_type_and_owner_id"
  end

  create_table "ruby_llm_mcp_credentials", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_ruby_llm_mcp_credentials_on_key", unique: true
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_mcp_credentials_on_owner"
  end

  create_table "ruby_llm_models", force: :cascade do |t|
    t.string "model_id", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "family"
    t.datetime "model_created_at"
    t.integer "context_window"
    t.integer "max_output_tokens"
    t.date "knowledge_cutoff"
    t.datetime "unlisted_at"
    t.jsonb "modalities", default: {}
    t.jsonb "capabilities", default: []
    t.jsonb "pricing", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capabilities"], name: "index_ruby_llm_models_on_capabilities", using: :gin
    t.index ["family"], name: "index_ruby_llm_models_on_family"
    t.index ["modalities"], name: "index_ruby_llm_models_on_modalities", using: :gin
    t.index ["provider", "model_id"], name: "index_ruby_llm_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_ruby_llm_models_on_provider"
  end

  create_table "ruby_llm_provider_files", force: :cascade do |t|
    t.string "blob_key", null: false
    t.string "provider", null: false
    t.string "account", null: false
    t.text "file_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_key", "provider", "account"], name: "index_ruby_llm_provider_files_uniqueness", unique: true
  end

  create_table "ruby_llm_queued_messages", force: :cascade do |t|
    t.string "chat_type", null: false
    t.bigint "chat_id", null: false
    t.string "sender_type"
    t.bigint "sender_id"
    t.text "content"
    t.boolean "steer", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_type", "chat_id"], name: "index_ruby_llm_queued_messages_on_chat_type_and_chat_id"
    t.index ["sender_type", "sender_id"], name: "index_ruby_llm_queued_messages_on_sender_type_and_sender_id"
  end

  create_table "ruby_llm_tool_calls", force: :cascade do |t|
    t.string "message_type", null: false
    t.bigint "message_id", null: false
    t.string "result_type"
    t.bigint "result_id"
    t.string "tool_call_id", null: false
    t.string "name", null: false
    t.text "thought_signature"
    t.string "approval"
    t.boolean "remote", default: false, null: false
    t.jsonb "arguments", default: {}
    t.jsonb "mcp_state"
    t.jsonb "mcp_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider_call_id"
    t.string "namespace"
    t.datetime "claimed_until"
    t.index ["message_type", "message_id"], name: "index_ruby_llm_tool_calls_on_message_type_and_message_id"
    t.index ["name"], name: "index_ruby_llm_tool_calls_on_name"
    t.index ["result_type", "result_id"], name: "index_ruby_llm_tool_calls_on_result_type_and_result_id"
    t.index ["tool_call_id"], name: "index_ruby_llm_tool_calls_on_tool_call_id", unique: true
  end

  create_table "ruby_llm_usages", force: :cascade do |t|
    t.string "chat_type"
    t.bigint "chat_id"
    t.string "message_type"
    t.bigint "message_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "operation", null: false
    t.string "provider", null: false
    t.string "model", null: false
    t.string "status", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.integer "cache_read_tokens"
    t.integer "cache_write_tokens"
    t.integer "thinking_tokens"
    t.jsonb "server_tool_use"
    t.decimal "input_cost", precision: 16, scale: 10
    t.decimal "output_cost", precision: 16, scale: 10
    t.decimal "cache_read_cost", precision: 16, scale: 10
    t.decimal "cache_write_cost", precision: 16, scale: 10
    t.decimal "thinking_cost", precision: 16, scale: 10
    t.decimal "total_cost", precision: 16, scale: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_id"
    t.string "workflow_name"
    t.string "workflow_step_id"
    t.string "workflow_step_name"
    t.integer "characters"
    t.decimal "audio_seconds", precision: 16, scale: 6
    t.integer "search_units"
    t.decimal "characters_cost", precision: 16, scale: 10
    t.decimal "audio_seconds_cost", precision: 16, scale: 10
    t.decimal "search_units_cost", precision: 16, scale: 10
    t.index ["chat_type", "chat_id"], name: "index_ruby_llm_usages_on_chat_type_and_chat_id"
    t.index ["message_type", "message_id"], name: "index_ruby_llm_usages_on_message_type_and_message_id"
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_usages_on_owner_type_and_owner_id"
    t.index ["status"], name: "index_ruby_llm_usages_on_status"
    t.index ["workflow_id"], name: "index_ruby_llm_usages_on_workflow_id"
    t.check_constraint "operation::text = ANY (ARRAY['chat'::text, 'embedding'::text, 'moderation'::text, 'image'::text, 'speech'::text, 'transcription'::text, 'ocr'::text, 'rerank'::text, 'judgment'::text, 'video'::text, 'research'::text, 'code_execution'::text])"
    t.check_constraint "status::text = ANY (ARRAY['pending'::text, 'succeeded'::text, 'failed'::text, 'cancelled'::text])"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chats", "ruby_llm_models"
  add_foreign_key "messages", "chats"
end
