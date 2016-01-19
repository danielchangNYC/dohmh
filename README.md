# DOHMH NYC Restaurant Inspection Results

This recommends restaurants based on cuisine type and overall health rating.

## Setup

1. Download the [DOHMH NYC Restaurant Inspection Results](https://nycopendata.socrata.com/api/views/xx67-kt59/rows.csv?accessType=DOWNLOAD)
2. Move the CSV to `lib/results.csv`
3. Run `rake db:create`
4. Run `rake db:migrate`
5. Run `rake csv:parse` to seed the database using the CSV
6. Run `shotgun` to start your server on port 9393
