#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js'
import fs from 'fs'
import { parse } from 'csv-parse/sync'

async function importCSV() {
  // ← hard-coded, so cron doesn’t need to export anything
  const SUPABASE_URL = 'https://zikyldcitoqkbfkipoxe.supabase.co'
  const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inppa3lsZGNpdG9xa2Jma2lwb3hlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MDgwNzI1OSwiZXhwIjoyMDY2MzgzMjU5fQ.A8y6YzBn8VzAqzgmBpt3odi3dP4vldq4nApprTYZUxQ'

  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

  const content = fs.readFileSync('/mnt/shared/db_data/tagassignment_data.csv')
  const rows    = parse(content, { columns: true })

  // dedupe so you don’t hit that ON CONFLICT twice error
  const deduped = Object.values(
    rows.reduce((acc, row) => {
      acc[row.TagID] = row
      return acc
    }, {})
  )

  const { error } = await supabase
    .from('CurrentLocation')
    .upsert(deduped, { onConflict: 'TagID' })

  if (error) {
    console.error('Import failed:', error)
    process.exit(1)
  }

  console.log(`✅ Import attempted for ${deduped.length} rows`)
}

importCSV()
