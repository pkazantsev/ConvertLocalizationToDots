# Convert Localization To Dots
Command line tool that replaces underscores in iOS localization file keys with dots so that 
tools like [SwiftGen](https://github.com/SwiftGen/SwiftGen) could correctly convert them to enums.


## Using
The app accepts two required arguments – source file path and destination file path, like this:
```
# ConvertLocalizationToDots ~/Documents/Localizable_underscores.strings ~/Documents/MyApp/en.lproj/Localizable.strings
```

Also, you can set path to a config file with optional argiment `--config`

## Config file

Configuration file consists of 3 sections: _keys_to_split_, _keys_to_not_split_ and _filters_.

Every value is these sections should be preceeded by a tab, or 2 or more spaces.

First two sections contain list of key prefixes after which an underscore should be, or should not be, replaced with a dot.
_Filters_ section contains list of rules by which every row is validated.

A row can be filtered by a key and by a comment. Available rules are `!empty`, `!eq`, `!prefix`, `!suffix`, `!contains`.

### Example of a config file

```
keys_to_split:
    "confirm"
    "shortcut"

keys_to_not_split:
    "application"
    "registration.phone"
    "send"
    "settings.use"

filters:
    key !empty
    comment !eq "для WP"
    key !prefix "windows"
    key !suffix "wp"
    key !contains "android"
    key !contains "nfc"
```

## Example

Say, you have a localization file like this:
```
"order_payment_methods_add_payment_method_msg"      = "Enter a new payment method title";
"order_payment_methods_add_payment_method_title"    = "Add Payment Method";
"order_payment_methods_edit_payment_method_msg"     = "Change a payment method title";
"order_payment_methods_edit_payment_method_title"   = "Edit Payment Method";
"order_payment_methods_view_title_select_multiple"  = "Select Payment Methods";
"order_payment_methods_view_title_select_one"       = "Select a Payment Method";
"order_payment_methods_view_title"                  = "Payment Methods";
"order_settings_list_view_title"                    = "Orders Settings";
"order_settings_list_order_payment_methods"         = "Order Payment Methods";
"order_settings_list_order_statuses"                = "Order Statuses";
"order_status_details_view_order_status"            = "Status";
"order_status_details_view_status_commentary"       = "Commentary";
"order_status_details_view_status_set_date"         = "Setting date";
```

After conversion you'll get next result:
```
"order.payment_methods.add_payment_method.msg" = "Enter a new payment method title";
"order.payment_methods.add_payment_method.title" = "Add Payment Method";
"order.payment_methods.edit_payment_method.msg" = "Change a payment method title";
"order.payment_methods.edit_payment_method.title" = "Edit Payment Method";
"order.payment_methods.view_title" = "Payment Methods";
"order.payment_methods.view_title_select.multiple" = "Select Payment Methods";
"order.payment_methods.view_title_select.one" = "Select a Payment Method";
"order.settings_list.order.payment_methods" = "Order Payment Methods";
"order.settings_list.order.statuses" = "Order Statuses";
"order.settings_list.view_title" = "Orders Settings";
"order.status_details_view.order_status" = "Status";
"order.status_details_view.status.commentary" = "Commentary";
"order.status_details_view.status.set_date" = "Setting date";
```

And, if you'd used `SwiftGen` tool, you'd get this lovely enum:
```swift
 enum L10n {

   enum Order {

     enum PaymentMethods {
       static let viewTitle = L10n.tr("Localizable", "order.payment_methods.view_title")

       enum AddPaymentMethod {
         static let msg = L10n.tr("Localizable", "order.payment_methods.add_payment_method.msg")
         static let title = L10n.tr("Localizable", "order.payment_methods.add_payment_method.title")
      }

       enum EditPaymentMethod {
         static let msg = L10n.tr("Localizable", "order.payment_methods.edit_payment_method.msg")
         static let title = L10n.tr("Localizable", "order.payment_methods.edit_payment_method.title")
      }

       enum ViewTitleSelect {
         static let multiple = L10n.tr("Localizable", "order.payment_methods.view_title_select.multiple")
         static let one = L10n.tr("Localizable", "order.payment_methods.view_title_select.one")
      }
    }

     enum SettingsList {
       static let viewTitle = L10n.tr("Localizable", "order.settings_list.view_title")

       enum Order {
         static let paymentMethods = L10n.tr("Localizable", "order.settings_list.order.payment_methods")
         static let statuses = L10n.tr("Localizable", "order.settings_list.order.statuses")
      }
    }

     enum StatusDetailsView {
       static let orderStatus = L10n.tr("Localizable", "order.status_details_view.order_status")

       enum Status {
         static let commentary = L10n.tr("Localizable", "order.status_details_view.status.commentary")
         static let setDate = L10n.tr("Localizable", "order.status_details_view.status.set_date")
       }
     }
   }
 }
```
