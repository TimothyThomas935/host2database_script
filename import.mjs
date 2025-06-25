// import.mjs
import { createClient } from '@supabase/supabase-js'
import fs from 'fs'
import { parse } from 'csv-parse/sync'

async function importCSV() {
  // 1) init client
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
  )

  // 2) read & parse
  const content = fs.readFileSync('/mnt/shared/db_data/tagassignment_data.csv')
  const rows = parse(content, { columns: true })

  console.log(`Parsed ${rows.length} rows. First row:`, rows[0])

  // 3) upsert into CurrentLocation (PK = TagID)
  const { error } = await supabase
    .from('CurrentLocation')
    .upsert(rows, { onConflict: 'TagID' })

  if (error) {
    console.error('Import failed:', error)
    process.exit(1)
  }

  // 4) just report how many you attempted
  console.log('✅ Import attempted for', rows.length, 'rows')
}

importCSV()
