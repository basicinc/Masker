# Mongodb-data-masking
Masking your data in mongodb

# Usage
```
bundle
ruby masker.rb mask mask.yml
```

# Example mask.yml
```yaml
version: 1
db_url: mongodb://mongodb:27017/development
models:
  - name: users
    condition:
      email:
        "$not": !ruby/regexp '/@basicinc\.jp$/'
    fields:
      email: FFaker::Internet.safe_email
  - name: users
    fields:
      reset_password_token: String.new
      confirmation_token: String.new
  - name: sitesconta
    fields:
      title: FFaker::NameJA.name
      description: FFaker::LoremJA.sentence
      domain: FFaker::Internet.domain_name
      external_service: :external_services
  - name: external_services
    fields:
      _type: "'ExternalService'"
      facebook: nil
      google: nil
  - name: contacts
    condition:
      site_id:
        "$ne": BSON::ObjectId('12312345346456456456sdff')
    delete: true
```
