/*
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS user_institutions;
DROP TABLE IF EXISTS institutions;
DROP TABLE IF EXISTS users;
*/

/************************************************************************************************************
extensions
************************************************************************************************************/

CREATE EXTENSION tablefunc;
CREATE EXTENSION citext;

/************************************************************************************************************
Lookup tables
************************************************************************************************************/
-- https://plaid.com/docs/errors/item/#access_not_granted
DROP TABLE IF EXISTS plaid_errors;

CREATE TABLE IF NOT EXISTS plaid_errors
(
   id SERIAL PRIMARY KEY
 , error_type citext
 , error_code citext
 , subtitle citext
 , is_server_side boolean
 , is_client_side boolean
 , common_causes citext
 , troubleshooting citext
 , sample_response jsonb
 , user_friendly_error citext
);

insert into plaid_errors(error_type,error_code, subtitle, is_server_side, is_client_side, common_causes, troubleshooting,sample_response,user_friendly_error) values
('ITEM_ERROR','ACCESS_NOT_GRANTED','The user did not grant necessary permissions for their account.','TRUE','FALSE','<ul><li>This Item''s access is affected by institution-hosted access controls.</li><li>The user did not agree to share, or has revoked, access to the data required for the requested product. Note that for some institutions, the end user may need to specifically opt-in during the OAuth flow to share specific details, such as identity data, or account and routing number information, even if they have already opted in to sharing information about a specific account.</li></ul>','<ul><li>Prompt the end user to allow Plaid to access identity data and/or account and routing number data. The end user should do this during the Link flow if they were unable to successfully complete the Link flow for the Item, or via Link‚Äôs <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/link/update-mode/"><span class="InlineLink-module_text__3pIL1">update mode</span></a> if the Item has already been added.</li><li>If there are other security settings on the user''s account that prevent sharing data with aggregators, they should adjust their security preferences on their institution''s online banking portal. It may take up to 48 hours for changes to take effect.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "ACCESS_NOT_GRANTED", "error_message": "access to this product was not granted for the account", "display_message": "The user did not grant the necessary permissions for this product on their account.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','INSTANT_MATCH_FAILED','Instant Match could not be initialized for the Item.','TRUE','FALSE','<ul><li>Instant Auth could not be used for the Item, and Instant Match has been enabled for your account, but a country other than <code>US</code> is specified in Link''s country code initialization.</li><li>The Item does not support Instant Auth or Instant Match. If this is the case, Plaid will automatically attempt to enter a micro-deposit based verification flow.</li></ul>','<ul><li>Update the countries used to initialize Link. Instant Match can only be used when Link is initialized with <code>US</code> as the only country code.</li><li>Review Link activity logs to verify whether a micro-deposit verification flow was launched in Link after this error occurred. If it was not launched, see <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://plaid.com/docs/auth/coverage/" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Add institution coverage</span></a> for more information on enabling micro-deposit verification flows. If it was launched successfully, no further troubleshooting action is required.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "INSTANT_MATCH_FAILED", "error_message": "Item cannot be verified through Instant Match. Ensure you are correctly enabling all auth features in Link.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','INSUFFICIENT_CREDENTIALS','The user did not provide sufficient authorization in order to link their account via an OAuth login flow.','TRUE','TRUE','<ul><li>Your user abandoned the bank OAuth flow without completing it.</li></ul>','<ul><li>Have your user attempt to link their account again.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "INSUFFICIENT_CREDENTIALS", "error_message": "insufficient authorization was provided to complete the request", "display_message": "INSUFFICIENT_CREDENTIALS", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','INVALID_CREDENTIALS','The financial institution indicated that the credentials provided were invalid.Link user experience','FALSE','TRUE','<ul><li>The user entered incorrect credentials at their selected institution.<ul><li>Extra spaces, capitalization, and punctuation errors are common causes of <code>INVALID_CREDENTIALS</code>.</li></ul></li><li>The institution requires special configuration steps before the user can link their account with Plaid. KeyBank and Betterment are two examples of institutions that require this setup.</li><li>The user selected the wrong institution.<ul><li>Plaid supports institutions that have multiple login portals for the various products they offer, and it is common for users to confuse a different selection for the one which their credentials would actually be accepted.</li><li>For example: a user may have selected <code>Fidelity</code> instead of <code>Fidelity - NetBenefits</code>. This confusion is particularly common between Fidelity (brokerage accounts) and Fidelity NetBenefits (retirement accounts) and between Vanguard (brokerage accounts) and My Vanguard Plan (retirement accounts). This is also common for users attempting to link prepaid stored-value cards, as many institutions have separate login portals specifically for those cards.</li></ul></li></ul>','<ul><li>Prompt your user to retry entering their credentials.</li><li>Confirm that the credentials being entered are correct by asking the user to test logging in to their financial institution website using the same set of credentials.</li><li>The user should check their financial institution website for special settings to allow access for third-party apps, such as a "third party application password" or "allow third party access" setting.</li><li>Verify that the user is selecting the correct institution in Link‚Äôs Institution Select view.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "INVALID_CREDENTIALS", "error_message": "the provided credentials were not correct", "display_message": "The provided credentials were not correct. Please try again.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','INVALID_SEND_METHOD','Returned when the method used to send MFA credentials was deemed invalid by the institution.Link user experience','FALSE','TRUE','<ul><li>The institution is experiencing login issues.</li><li>The integration between Plaid and the financial institution is experiencing errors.</li></ul>','<ul><li>If the error persists, submit a ''Multi-factor authentication issues'' <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support/new/financial-institutions/authentication-issues/mfa-issue" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Support</span></a> ticket with the following identifiers: <code>institution_id</code> and either <code>link_session_id</code> or <code>request_id</code>.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "INVALID_SEND_METHOD", "error_message": "the provided MFA send_method was invalid", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','INVALID_UPDATED_USERNAME','The username entered during update mode did not match the original username.Link user experience','FALSE','TRUE','<ul><li>While linking an account in <a href="/docs/link/update-mode/"><span>update mode</span></a>, the user provided a username that doesn''t match the original username provided when they originally linked the account.</li></ul>','<ul><li>If your user entered the wrong username, or the username for a different account, they should enter the correct, original username.</li><li>Have your user ensure that the capitalization for their username is the same as it was when they first logged in to Plaid. The username entered during update mode must case-match with the original username, even if the institution does not consider usernames case-sensitive.</li><li>If your user actually changed the username for the account, you should delete the original Item and direct your user to the regular Link flow to link their account as a new Item.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "INVALID_UPDATED_USERNAME", "error_message": "the username provided to /item/credentials/update does not match the original username for the item", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','ITEM_CONCURRENTLY_DELETED','This item was deleted while the operation was in progress.','FALSE','FALSE','<ul><li>An Item was deleted via <a href="/docs/api/items/#itemremove"><span><code>/item/remove</code></span></a> while a request for its data was in process.</li></ul>','<ul><li>If you plan to delete an Item immediately after retrieving data from it, make sure to wait until your request has successfully returned the data you need before calling <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemremove"><span class="InlineLink-module_text__3pIL1"><code>/item/remove</code></span></a>.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "ITEM_CONCURRENTLY_DELETED", "error_message": "This item was deleted while the operation was in progress", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','ITEM_LOCKED','The financial institution indicated that the user''s account is locked. The user will need to work with the institution directly to unlock their account.Link user experience','FALSE','TRUE','<ul><li>The user entered their credentials incorrectly after more than 3-5 attempts, triggering the institution‚Äôs fraud protection systems and locking the user‚Äôs account.</li></ul>','<ul><li>Request that the user log in directly to their institution. Attempting to log in is a reliable way of confirming whether the user‚Äôs account is legitimately locked with a given institution. If the user cannot log in due to their account being locked, the website will usually note it as such, giving supplemental information on what they can do to resolve their account.</li><li>If the account is locked, ask the user to work with the financial institution to unlock their account.</li><li>Steps on unlocking an account are usually provided when a login attempt fails with the institution directly, in the event that their account is actually locked. Once unlocked, they should then try to re-authenticate using Plaid Link.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "ITEM_LOCKED", "error_message": "the account is locked. prompt the user to visit the institution''s site and unlock their account", "display_message": "The given account has been locked by the financial institution. Please visit your financial institution''s website to unlock your account.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','ITEM_LOGIN_REQUIRED','The financial institution indicated that the user''s password or MFA information has changed. They will need to reauthenticate via Link''s update mode.Developer experience','TRUE','FALSE','<ul><li>The user changed their password.</li><li>The user changed their multi-factor authentication device, questions, or answers.</li><li>The institution updated its multi-factor security protocols.</li><li>The institution uses an OAuth-based connection and the user''s access-consent has expired.</li><li>Your integration has switched to using an OAuth-based connection to the user''s institution.</li></ul>','<ul><li>Re-authenticate your user by implementing Link‚Äôs <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/link/update-mode/"><span class="InlineLink-module_text__3pIL1">update mode</span></a> and guide your user to fix their credentials so Plaid can begin fetching data again.</li><li>If the Item is on an OAuth-based connection and has an expired <code>consent_expiration_time</code>, you may be able to reduce the frequency of this error by listening for the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#pending_expiration"><span class="InlineLink-module_text__3pIL1"><code>PENDING_EXPIRATION</code></span></a> webhook and proactively sending the user through update mode before the Item expires.</li><li>If the affected institution is Capital One (<code>ins_9</code>) and the Item has not yet been migrated to the new Capital One institution record (<code>ins_128026</code>), delete the Item using <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemremove"><span class="InlineLink-module_text__3pIL1"><code>/item/remove</code></span></a> and prompt your user to re-add it in order to migrate it to the new institution. For more information, refer to the migration guide provided via email from Plaid.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "ITEM_LOGIN_REQUIRED", "error_message": "the login details of this item have changed (credentials, MFA, or required user action) and a user login is required to update this information. use Link''s update mode to restore the item to a good state", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','ITEM_NOT_FOUND','The Item you requested cannot be found. This Item does not exist, has been previously removed via /item/remove, or has had access removed by the user','TRUE','FALSE','<ul><li>Item was previously removed via <a href="/docs/api/items/#itemremove"><span><code>/item/remove</code></span></a>.</li><li>The user has depermissioned or deleted their Item via <a href="http://my.plaid.com" target="_blank" rel="nofollow noopener noreferrer"><span>my.plaid.com</span></a>.</li></ul>','<ul><li>Launch a new instance of Plaid Link and prompt the user to create a new Item.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "ITEM_NOT_FOUND", "error_message": "The Item you requested cannot be found. This Item does not exist, has been previously removed via /item/remove, or has had access removed by the user.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','ITEM_NOT_SUPPORTED','Plaid is unable to support this user''s accounts due to restrictions in place at the financial institution.Link user experience','FALSE','TRUE','<ul><li>Plaid does not currently support the types of accounts for the the connected Item, due to restrictions in place at the selected institution.</li><li>Plaid does not currently support the specific type of multi-factor authentication in place at the selected institution.</li><li>The credentials provided are for a ''guest'' account or other account type with limited account access.</li></ul>','<ul><li>Prompt the user to connect a different account and institution.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "ITEM_NOT_SUPPORTED", "error_message": "this account is currently not supported", "display_message": "The given account is not currently supported for this financial institution. We apologize for the inconvenience.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','MFA_NOT_SUPPORTED','Returned when the user requires a form of MFA that Plaid does not support for a given financial institution.Link user experience','FALSE','TRUE','<ul><li>Plaid does not currently support the specific type of multi-factor authentication in place at the selected institution.</li><li>The user''s multi-factor authentication setting is configured not to remember trusted devices and instead to present a multi-factor challenge on every login attempt. This prevents Plaid from refreshing data asynchronously, which many products (especially Transactions) require.</li></ul>','<ul><li>Prompt the user to connect a different account and institution.</li><li>If your application does not require asynchronous data refresh to work properly, <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support/new/" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">contact Support</span></a> to explore your options for enabling user access.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "MFA_NOT_SUPPORTED", "error_message": "this account requires a MFA type that we do not currently support for the institution", "display_message": "The multi-factor security features enabled on this account are not currently supported for this financial institution. We apologize for the inconvenience.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','NO_ACCOUNTS','Returned when there are no open accounts associated with the Item.Link user experience','FALSE','TRUE','<ul><li>The user successfully logged into their account, but Plaid was unable to retrieve any open or active accounts in the connected Item.</li><li>The user closed their account.</li></ul>','<ul><li>Prompt the user to connect a different account and institution.</li><li>If the user no longer has any accounts associated with the Item, remove the Item via <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemremove"><span class="InlineLink-module_text__3pIL1"><code>/item/remove</code></span></a>.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "NO_ACCOUNTS", "error_message": "no valid accounts were found for this item", "display_message": "No valid accounts were found at the financial institution. Please visit your financial institution''s website to confirm accounts are available.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','NO_AUTH_ACCOUNTS','Returned from POST /auth/get when there are no valid checking or savings account(s) for which account and routing numbers could be retrieved.','TRUE','TRUE','<ul><li><a href="/docs/api/products/auth/#authget"><span><code>/auth/get</code></span></a> was called on an Item with no accounts that can support Auth, or accounts that do support Auth were filtered out. Only debitable checking and savings accounts can be used with Auth.</li><li>Plaid''s ability to retrieve Auth data from the institution has been temporarily disrupted.</li><li>The end user is connecting to an institution that uses OAuth-based flows but did not grant permission in the OAuth flow for the institution to share details for any debitable checking and savings accounts. Note that for some institutions, the end user may need to specifically opt-in during the OAuth flow to share account and routing number information even if they have already opted in to sharing information about their checking or savings account.</li></ul>','<ul><li>Ensure that any <code>account_id</code> specified in the <code>options</code> filter for <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/auth/#authget"><span class="InlineLink-module_text__3pIL1"><code>/auth/get</code></span></a> belongs to a debitable checking or savings account. </li><li>Ensure that the end user has a debitable checking or savings account at the institution. Not all savings and checking accounts permit ACH debits. Common examples of non-debitable accounts include savings accounts at Chime or at Navy Federal Credit Union (NFCU).</li><li>If the Item is at an OAuth-based institution, prompt the end user to allow Plaid to access a debitable checking or savings account, along with its account and routing number data. The end user should do this during the Link flow if they were unable to successfully complete the Link flow for the Item, or at their institution''s online banking portal if the Item has already been added.</li><li>Return your user to the Link flow and prompt them to link a different account.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "NO_AUTH_ACCOUNTS", "error_message": "There are no valid checking or savings account(s) associated with this Item. See https://plaid.com/docs/api/#item-errors for more.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','NO_INVESTMENT_ACCOUNTS','Returned from POST /investments/holdings/get, POST /investments/transactions/get, or Link initialized with the Investments product, when there are no valid investment account(s) for which holdings or transactions could be retrieved.','TRUE','TRUE','<ul><li>Link was initialized with the Investments product, but the user attempted to link an account with no investment accounts.</li><li>The <a href="/docs/api/products/investments/#investmentsholdingsget"><span><code>/investments/holdings/get</code></span></a> or <a href="/docs/api/products/investments/#investmentstransactionsget"><span><code>/investments/transactions/get</code></span></a> endpoint was called, but there are no investment accounts associated with the Item.</li><li>The end user is connecting to an institution that uses OAuth-based flows but did not grant permission in the OAuth flow for the institution to share details for any investment accounts.</li></ul>','<ul><li>Have the user open an investment account at the institution and then re-link, or link an Item that already has an investment account.</li><li>If your end user is connecting to an institution that uses OAuth-based flows (one for which the <code>oauth</code> field in the institution record is <code>true</code>), ensure that your end user consented to share details for an investment account.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "NO_INVESTMENT_ACCOUNTS", "error_message": "There are no valid investment account(s) associated with this Item. See https://plaid.com/docs/api/#item-errors for more information.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','NO_INVESTMENT_AUTH_ACCOUNTS','Returned from POST /investments/holdings/get or POST /investments/transactions/get when there are no valid investment account(s) for which holdings or transactions could be retrieved.','TRUE','FALSE','<ul><li>The <a href="/docs/api/products/investments/#investmentsholdingsget"><span><code>/investments/holdings/get</code></span></a> or <a href="/docs/api/products/investments/#investmentstransactionsget"><span><code>/investments/transactions/get</code></span></a> endpoint was called, but there are no investment accounts associated with the Item.</li><li>The end user is connecting to an institution that uses OAuth-based flows but did not grant permission in the OAuth flow for the institution to share details for any investment accounts.</li></ul>','<ul><li>Have the user open an investment account at the institution and then re-link, or link an Item that already has an investment account. If the user links a new Item, delete the old one via <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemremove"><span class="InlineLink-module_text__3pIL1"><code>/item/remove</code></span></a>.</li><li>If your end user is connecting to an institution that uses OAuth-based flows (one for which the <code>oauth</code> field in the institution record is <code>true</code>), ensure that your end user consented to share details for an investment account.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "NO_INVESTMENT_AUTH_ACCOUNTS", "error_message": "There are no valid investment account(s) associated with this Item. See https://plaid.com/docs/api/#item-errors for more information.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','NO_LIABILITY_ACCOUNTS','Returned from POST /liabilities/get when there are no valid liability account(s) for which liabilities could be retrieved.','TRUE','FALSE','<ul><li>The <a href="/docs/api/products/liabilities/#liabilitiesget"><span><code>/liabilities/get</code></span></a> endpoint was called, but there are no supported liability accounts associated with the Item.</li><li>The end user is connecting to an institution that uses OAuth-based flows but did not grant permission in the OAuth flow for the institution to share details for any liabilities accounts.</li></ul>','<ul><li>Make sure the user has linked an Item with a supported account type and subtype. The account types supported for the Liabilities product are <code>credit</code> accounts with the subtype of <code>credit card</code> or <code>paypal</code>, and <code>loan</code> accounts with the subtype of <code>student loan</code> or <code>mortgage</code>.</li><li>If your end user is connecting to an institution that uses OAuth-based flows (one for which the <code>oauth</code> field in the institution record is <code>true</code>), ensure that your end user consented to share details for a credit card, student loan, PayPal credit account, or mortgage.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "NO_LIABILITY_ACCOUNTS", "error_message": "There are no valid liability account(s) associated with this Item. See https://plaid.com/docs/api/#item-errors for more information.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','PRODUCT_NOT_ENABLED','A requested product was not enabled for the current access token. Please ensure it is included when when initializing Link and create the Item again.Common causes','TRUE','FALSE','<ul><li>You requested a product that was not enabled for the current access token. Ensure it is included when when calling <a href="/docs/api/tokens/#linktokencreate"><span><code>/link/token/create</code></span></a> and create the Item again.</li></ul>','','{ "error_type": "ITEM_ERROR", "error_code": "PRODUCT_NOT_ENABLED", "error_message": "A requested product was not enabled for the current access token. Please ensure it is included when when initializing Link and create the Item again.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','PRODUCT_NOT_READY','Returned when a data request has been made for a product that is not yet ready.','TRUE','FALSE','<ul><li><a href="/docs/api/products/transactions/#transactionsget"><span><code>/transactions/get</code></span></a> was called before the first 30 days of transaction data could be pulled.</li><li><a href="/docs/api/products/auth/#authget"><span><code>/auth/get</code></span></a> was called on an Item that hasn''t been verified, which is possible when using <a href="/docs/auth/coverage/"><span>micro-deposit based verification</span></a>.</li></ul>','<ul><li>If you know at the point of Link initialization that you will want to use Transactions with the linked Item, initialize Link with Transactions in order to start the product initialization process ahead of time.</li><li>Listen for the <code>INITIAL_UPDATE</code> webhook fired when the Transactions product is ready and only call <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/transactions/#transactionsget"><span class="InlineLink-module_text__3pIL1"><code>/transactions/get</code></span></a> after that webhook has been fired.</li><li>(If using Auth) Verify the Item manually, or wait for automated verification to succeed.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "PRODUCT_NOT_READY", "error_message": "the requested product is not yet ready. please provide a webhook or try the request again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','PRODUCTS_NOT_SUPPORTED','Returned when a data request has been made for an Item for a product that it does not support. Use the /item/get endpoint to find out which products an Item supports.','TRUE','FALSE','<ul><li>A product endpoint request was made for an Item that does not support that product.</li><li>A product endpoint request was made for an Item at an OAuth-based institution, but the end user did not authorize the Item for the specific product, or has revoked Plaid''s access to the product. Note that for some institutions, the end user may need to specifically opt-in during the OAuth flow to share specific details, such as identity data, or account and routing number information, even if they have already opted in to sharing information about a specific account. (This usage is deprecated; see also <a href="/docs/errors/item/#access_not_granted"><span>ACCESS_NOT_GRANTED</span></a>)</li><li>Updated accounts have been requested for an Item initialized with the Assets product, which does not support adding or updating accounts after the initial Link.</li></ul>','<ul><li>Use the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemget"><span class="InlineLink-module_text__3pIL1"><code>/item/get</code></span></a> endpoint to determine which products a given Item supports.</li><li>Use the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/#institutionsget_by_id"><span class="InlineLink-module_text__3pIL1"><code>/institutions/get_by_id</code></span></a> endpoint to determine which products a given institution supports.</li><li>If the Item is at an OAuth-based institution, prompt the end user to allow Plaid to access identity data and/or account and routing number data. The end user should do this during the Link flow if they were unable to successfully complete the Link flow for the Item, or If the Item is at an OAuth-based institution, prompt the end user to allow Plaid to access identity data and/or account and routing number data. The end user should do this during the Link flow if they were unable to successfully complete the Link flow for the Item, or via Link''s <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/link/update-mode/"><span class="InlineLink-module_text__3pIL1">update mode</span></a> if the Item has already been added.</li><li>If receiving this error during <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/tokens/#linktokencreate"><span class="InlineLink-module_text__3pIL1"><code>/link/token/create</code></span></a> for update mode, and you are using the Item with the Assets product, you must instead create a new Item rather than updating the existing Item.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "PRODUCTS_NOT_SUPPORTED", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','USER_SETUP_REQUIRED','The user must log in directly to the financial institution and take some action before Plaid can access their accounts.Link user experience','FALSE','TRUE','<ul><li>The institution requires special configuration steps before the user can link their account with Plaid. KeyBank and Betterment are two examples of institutions that require this setup.</li><li>The user‚Äôs account is not fully set up at their institution.</li><li>The institution is blocking access due to an administrative task that requires completion. This error can arise for a number of reasons, the most common being:<ul><li>The user must agree to updated terms and conditions.</li><li>The user must reset their password.</li><li>The user must enter additional account information.</li></ul></li></ul>','<ul><li>Request that the user log in and complete their account setup directly at their institution.</li><li>Once completed, prompt the user to re-authenticate with Plaid Link.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "USER_SETUP_REQUIRED", "error_message": "the account has not been fully set up. prompt the user to visit the issuing institution''s site and finish the setup process", "display_message": "The given account is not fully setup. Please visit your financial institution''s website to setup your account.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ITEM_ERROR','USER_INPUT_TIMEOUT','The user did not complete a step in the Link flow, and it timed out.','FALSE','TRUE','<ul><li>Your user did not complete the account selection flow within five minutes.</li></ul>','<ul><li>Have your user attempt to link their account again.</li></ul>','{ "error_type": "ITEM_ERROR", "error_code": "USER_INPUT_TIMEOUT", "error_message": "user must retry this operation", "display_message": "The application timed out waiting for user input", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INCOME_VERIFICATION_ERROR','PRODUCT_NOT_ENABLED','The Income product has not been enabled.','TRUE','FALSE','<ul><li>The Income product has not been enabled.</li></ul>','<ul><li>Make sure to initialize Link with <code>income</code> in the <code>product</code> array.</li><li>Contact your Plaid Account Manager or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Plaid Support</span></a> to request that your account be enabled for Income Verification.</li></ul>','{ "error_type": "INCOME_VERIFICATION_ERROR", "error_code": "PRODUCT_NOT_ENABLED", "error_message": "the ''income_verification'' product is not enabled for the following client ID: <CLIENT_ID>. please ensure that the ''income_verification'' is included in the ''product'' array when initializing Link and try again.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INCOME_VERIFICATION_ERROR','INCOME_VERIFICATION_UPLOAD_ERROR','There was an error uploading income verification documents.','TRUE','TRUE','<ul><li>The end user''s Internet connection may have been interrupted during the upload attempt.</li></ul>','<ul><li>Plaid will prompt the end user to re-try uploading their documents.</li></ul>','{ "error_type": "INCOME_VERIFICATION_ERROR", "error_code": "INCOME_VERIFICATION_UPLOAD_ERROR", "error_message": "there was a problem uploading the document for verification. Please try again or recreate an income verification.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INCOME_VERIFICATION_ERROR','INCOME_VERIFICATION_FAILED','The income verification you are trying to retrieve could not be completed. please try creating a new income verification','TRUE','TRUE','<ul><li>The processing of the verification failed to complete successfully.</li></ul>','<ul><li>Have the user retry the verification.</li><li>If the problem persists, <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">contact Plaid Support</span></a>.</li></ul>','{ "error_type": "INCOME_VERIFICATION_ERROR", "error_code": "INCOME_VERIFICATION_FAILED", "error_message": "the income verification you are trying to retrieve could not be completed. please try creating a new income verification", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INCOME_VERIFICATION_ERROR','VERIFICATION_STATUS_PENDING_APPROVAL','The user has not yet authorized the sharing of this data','TRUE','FALSE','<ul><li>The user has not yet authorized access to the data.</li></ul>','<ul><li>Listen for the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/income/#income_verification"><span class="InlineLink-module_text__3pIL1">INCOME: INCOME_VERIFICATION</span></a> webhook with a corresponding <code>item_id</code>, which will fire once verification is complete.</li><li>Prompt the user to authorize access, then try again later.</li></ul>','{ "error_type": "INCOME_VERIFICATION_ERROR", "error_code": "VERIFICATION_STATUS_PENDING_APPROVAL", "error_message": "The user has not yet authorized the sharing of this data", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('SANDBOX_ERROR','SANDBOX_PRODUCT_NOT_ENABLED','The requested product is not enabled for an Item','TRUE','FALSE','<ul><li>A sandbox operation could not be performed because a product has not been enabled on the Sandbox Item.</li></ul>','<ul><li>Verify that you are enabled for the requested product in your <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a>.</li></ul>','{ "error_type": "SANDBOX_ERROR", "error_code": "SANDBOX_PRODUCT_NOT_ENABLED", "error_message": "The [auth | transactions | ...] product is not enabled on this item", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('SANDBOX_ERROR','SANDBOX_WEBHOOK_INVALID','The request to fire a Sandbox webhook failed.','TRUE','FALSE','<ul><li>The webhook for the Item sent in the <a href="/docs/api/sandbox/#sandboxitemfire_webhook"><span><code>/sandbox/item/fire_webhook</code></span></a> request is not set or is invalid.</li></ul>','<ul><li>Create a new Item with a valid webhook set.</li></ul>','{ "error_type": "SANDBOX_ERROR", "error_code": "SANDBOX_WEBHOOK_INVALID", "error_message": "Webhook for this item is either not set up, or invalid. Please update the item''s webhook and try again.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('SANDBOX_ERROR','SANDBOX_ACCOUNT_SELECT_V2_NOT_ENABLED','The item was not created with Account Select v2','TRUE','FALSE','<ul><li>A Sandbox operation could not be performed because the the Sandbox Item was not created with Account Select v2.</li></ul>','<ul><li>Create a new Item with <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/link/account-select-v2-migration-guide/"><span class="InlineLink-module_text__3pIL1">Account Select v2</span></a>.</li></ul>','{ "error_type": "SANDBOX_ERROR", "error_code": "SANDBOX_ACCOUNT_SELECT_V2_NOT_ENABLED", "error_message": "The item was not created with Account Select v2", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('SANDBOX_ERROR','SANDBOX_TRANSFER_EVENT_TRANSITION_INVALID','The /sandbox/transfer/simulate endpoint was called with parameters specifying an invalid event transition.','TRUE','FALSE','<ul><li>The <a href="/docs/api/sandbox/#sandboxtransfersimulate"><span><code>/sandbox/transfer/simulate</code></span></a> endpoint was called with parameters specifying an invalid event transition.</li></ul>','<ul><li>Ensure the sequence of events specified via <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/sandbox/#sandboxtransfersimulate"><span class="InlineLink-module_text__3pIL1"><code>/sandbox/transfer/simulate</code></span></a> is valid.</li><li>Compatible status --&gt; event type transitions include:</li><li><code>pending</code> --&gt; <code>failed</code></li><li><code>pending</code> --&gt; <code>posted</code></li><li><code>posted</code> --&gt; <code>reversed</code></li></ul>','{ "error_type": "SANDBOX_ERROR", "error_code": "SANDBOX_TRANSFER_EVENT_TRANSITION_INVALID", "error_message": "The provided simulated event type is incompatible with the current transfer status", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','INCOMPATIBLE_API_VERSION','The request uses fields that are not compatible with the API version being used.','TRUE','FALSE','<ul><li>The API endpoint was called using a <code>public_key</code> for authentication rather than a <code>client_id</code> and <code>secret</code>.</li></ul>','<ul><li>Review the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/"><span class="InlineLink-module_text__3pIL1">API Reference</span></a> for the endpoint to see what parameters are supported in the API version you are using.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "INCOMPATIBLE_API_VERSION", "error_message": "The public_key cannot be used for this endpoint as of version {version-date} of the API. Please use the client_id and secret instead.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','INVALID_ACCOUNT_NUMBER','The provided account number was invalid.','TRUE','TRUE','<ul><li>While in the Instant Match, Automated Micro-deposit, or Same-Day Micro-deposit Link flows, the user provided an account number whose last four digits did not match the account mask of their bank account.</li><li>If the user entered the correct account number, Plaid may have been unable to retrieve an account mask.</li></ul>','<ul><li>Have the user confirm that they entered the correct account number.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "INVALID_ACCOUNT_NUMBER", "error_message": "The provided account number was invalid.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','INVALID_BODY','The request body was invalid.','TRUE','FALSE','<ul><li>The JSON request body was malformed.</li><li>The request <code>content-type</code> was not of type <code>application/json</code>. The Plaid API only accepts JSON text as the MIME media type, with <code>UTF-8</code> encoding, conforming to <a href="http://www.ietf.org/rfc/rfc4627.txt" target="_blank" rel="nofollow noopener noreferrer"><span>RFC 4627</span></a>.</li></ul>','<ul><li>Resend the request with <code>content-type: ''application/json''</code>.</li><li>Resend the request with valid JSON in the body.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "INVALID_BODY", "error_message": "body could not be parsed as JSON", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','INVALID_CONFIGURATION','/link/token/create was called with invalid configuration settings','TRUE','FALSE','<ul><li>One or more of the configuration objects provided to <a href="/docs/api/tokens/#linktokencreate"><span><code>/link/token/create</code></span></a> does not match the request schema for that endpoint.</li></ul>','<ul><li>Verify that all field names being provided to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/tokens/#linktokencreate"><span class="InlineLink-module_text__3pIL1"><code>/link/token/create</code></span></a> match the schema for that endpoint. In particular, when migrating from Link tokens, note that some field names have changed between those used for Link token style Link configuration and those used as parameters for <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/tokens/#linktokencreate"><span class="InlineLink-module_text__3pIL1"><code>/link/token/create</code></span></a>.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "INVALID_CONFIGURATION", "error_message": "please ensure that the request body is formatted correctly", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','INVALID_FIELD','One or more of the request body fields were improperly formatted or an invalid type.','TRUE','FALSE','<ul><li>One or more fields in the request body were invalid, malformed, or used a wrong type. The <code>error_message</code> field will specify the erroneous field and how to resolve the error.</li><li>Personally identifiable information (PII), such as an email address or phone number, was provided for a field where PII is not allowed, such as <code>user.client_user_id</code>.</li><li>An unsupported country code was used in Production. Consult the <a href="/docs/api/"><span>API Reference</span></a> for the endpoint being used for a list of valid country codes.</li><li>An optional parameter was not provided in a context where it is required. For example, <a href="/docs/api/products/balance/#accountsbalanceget"><span><code>/accounts/balance/get</code></span></a> was called without specifying <code>options.min_last_updated_datetime</code> on an Item whose institution requires that parameter to be specified.</li></ul>','<ul><li>Resend the request with the correctly formatted fields specified in the <code>error_message</code>.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "INVALID_FIELD", "error_message": "{{ error message is specific to the given / missing request field }}", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','INVALID_HEADERS','The request was missing a required header.','TRUE','FALSE','<ul><li>The request was missing a <code>header</code>, typically the <code>Content-Type</code> header.</li></ul>','<ul><li>Resend the request with the missing headers.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "INVALID_HEADERS", "error_message": "{{ error message is specific to the given / missing header }}", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','MISSING_FIELDS','The request was missing one or more required fields.','TRUE','FALSE','<ul><li>The request body is missing one or more required fields. The <code>error_message</code> field will list the missing field(s).</li></ul>','<ul><li>Resend the request with the missing required fields specified in the <code>error_message</code>.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "MISSING_FIELDS", "error_message": "the following required fields are missing: {fields}", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','NO_LONGER_AVAILABLE','The endpoint requested is not available in the API version being used.','TRUE','FALSE','<ul><li>The endpoint you requested has been discontinued and no longer exists in the Plaid API.</li></ul>','<ul><li>Review the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/"><span class="InlineLink-module_text__3pIL1">API Reference</span></a> to see what endpoints are supported in the API version you are using.</li><li>See the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/link/link-token-migration-guide/"><span class="InlineLink-module_text__3pIL1">Link Token migration guide</span></a> for instructions on migrating away from endpoints that have been discontinued in recent API versions.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "NO_LONGER_AVAILABLE", "error_message": "This endpoint has been discontinued as of version {version-date} of the API.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','NOT_FOUND','The endpoint requested does not exist.','TRUE','FALSE','<ul><li>The endpoint you requested does not exist in the Plaid API.</li></ul>','<ul><li>Navigate to the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/"><span class="InlineLink-module_text__3pIL1">API reference</span></a> to find the correct API endpoint.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "NOT_FOUND", "error_message": "not found", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','SANDBOX_ONLY','The requested endpoint is only available in Sandbox.','TRUE','FALSE','<ul><li>The requested endpoint is only available in the <a href="/docs/sandbox/"><span>Sandbox API Environment</span></a>.</li></ul>','<ul><li>Change your environment to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/sandbox/"><span class="InlineLink-module_text__3pIL1">Sandbox</span></a> or remove usages of test endpoints.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "SANDBOX_ONLY", "error_message": "access to {api/route} is only available in the sandbox environment at https://sandbox.plaid.com/", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_REQUEST','UNKNOWN_FIELDS','The request included a field that is not recognized by the endpoint.','TRUE','FALSE','<ul><li>The request body included one or more extraneous fields. The <code>error_message</code> field will list the unrecognized field(s).</li></ul>','<ul><li>Resend the request with the omitted fields specified in the <code>error_message</code>.</li></ul>','{ "error_type": "INVALID_REQUEST", "error_code": "UNKNOWN_FIELDS", "error_message": "the following fields are not recognized by this endpoint: {fields}", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','DIRECT_INTEGRATION_NOT_ENABLED','An attempt was made to create an Item without using Link.','TRUE','FALSE','<ul><li><code>/item/create</code> was called directly, without using Link.</li></ul>','<ul><li>In the Development or Production environments, use Link to create the Item. In Sandbox, use <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/sandbox/#sandboxpublic_tokencreate"><span class="InlineLink-module_text__3pIL1"><code>/sandbox/public_token/create</code></span></a></li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "DIRECT_INTEGRATION_NOT_ENABLED", "error_message": "your client ID is only authorized to use Plaid Link. head to the docs (https://plaid.com/docs) to get started.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INCORRECT_DEPOSIT_AMOUNTS','The user submitted incorrect Manual Same-Day micro-deposit amounts during Item verification in Link.','TRUE','TRUE','<ul><li>Your user submitted incorrect micro-deposit amounts when verifying an account via Manual Same-Day micro-deposits.</li></ul>','<ul><li>Have your user attempt to enter the micro-deposit amounts again.</li><li>If your user has entered incorrect micro-deposit amounts three times, the Item will be permanently locked. In this case, you must restart the Link flow from the beginning and have the user re-link their account.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INCORRECT_DEPOSIT_AMOUNTS", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_ACCESS_TOKEN','','TRUE','FALSE','<ul><li>Access tokens are in the format: <code>access-&lt;environment&gt;-&lt;identifier&gt;</code></li><li>This error can happen when the <code>access_token</code> you provided is invalid, pertains to a different API environment, or has been removed, either via an <a href="/docs/api/items/#itemremove"><span><code>/item/remove</code></span></a> request or by the end user through <a href="https://my.plaid.com" target="_blank" rel="nofollow noopener noreferrer"><span>my.plaid.com</span></a>.</li></ul>','<ul><li>Make sure you are not using a token created in one environment in a different environment (for example, using a Sandbox token in the Development environment).</li><li>Ensure that the <code>client_id</code>, <code>secret</code>, and <code>access_token</code> are all associated with the same Plaid developer account.</li><li>Check your <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard logs</span></a> to see whether the <code>access_token</code> is associated with an Item that has been removed. If the <code>access_token</code> has been removed via <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemremove"><span class="InlineLink-module_text__3pIL1"><code>/item/remove</code></span></a>, the user will need to re-enter the Link flow to link their Item again.</li><li>If you have their permission to do so, ask the user whether they have revoked access via <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://my.plaid.com" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">my.plaid.com</span></a>. If your user has indeed revoked permission, they will need to re-enter the Link flow to connect their Item again.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_ACCESS_TOKEN", "error_message": "could not find matching access token", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_ACCOUNT_ID','The supplied account_id is not valid','TRUE','FALSE','<ul><li>Your integration is passing a correctly formatted, but invalid <code>account_id</code> for the Item in question.</li><li>The underlying account may have been closed at the bank, and thus removed from our API.</li><li>The Item affected is at an institution that uses OAuth-based connections, and the user revoked access to the specific account.</li><li>The <code>account_id</code> was erroneously removed from our API, either completely or a new <code>account_id</code> was assigned to the same underlying account.</li><li>You are requesting an account that your user has de-selected in the Account Select v2 update flow.</li></ul>','<ul><li>Verify that your integration is passing in correctly formatted and valid <code>account_id</code>(s)</li><li>Verify the Item''s currently active accounts and their <code>account_id</code>(s).</li><li>If the Item is at an institution that uses OAuth-based connections, the user may have revoked access to the account. If this is the case, It is a security best practice to give the user a choice between restoring their account and having your app delete all data for that account. If your user wants to restore access to the account, you can put them through <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/link/update-mode/"><span class="InlineLink-module_text__3pIL1">update mode</span></a>, which will give them the option to grant access to the account again.</li><li>Verify that after completing update mode, your implementation checks for the current <code>account_id</code> information associated with the Item, instead of re-using the pre-update mode <code>account_id</code>(s). Updated <code>account_id</code> data can be found in the <code>onSuccess</code> Link event, or by calling certain endpoints, such as <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemget"><span class="InlineLink-module_text__3pIL1"><code>/item/get</code></span></a>.</li><li>Verify that the <code>account_id</code> was not erroneously removed from the API.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_ACCOUNT_ID", "error_message": "failed to find requested account ID for requested item", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_API_KEYS','The client ID and secret included in the request body were invalid. Find your API keys in the Dashboard.','TRUE','FALSE','<ul><li>The API keys are not valid for the environment being used, which can commonly happen when switching between development environments and forgetting to switch API keys</li></ul>','<ul><li>Find your API keys in the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/team/keys" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a>.</li><li>Make sure you are using the secret that corresponds to the environment you are using (Sandbox, Development, or Production).</li><li>Make sure you are not using a token created in one environment in a different environment (for example, using a Sandbox token in the Development environment).</li><li>Visit the Plaid <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a> to verify that you are enabled for the environment you are using.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_API_KEYS", "error_message": "invalid client_id or secret provided", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_AUDIT_COPY_TOKEN','The audit copy token supplied to the server was invalid.','TRUE','FALSE','<ul><li>You attempted to access an Asset Report using an <code>audit_copy_token</code> that is invalid or was revoked using <a href="/docs/api/products/assets/#asset_reportaudit_copyremove"><span><code>/asset_report/audit_copy/remove</code></span></a> or <a href="/docs/api/products/assets/#asset_reportremove"><span><code>/asset_report/remove</code></span></a>.</li></ul>','<ul><li>Generate a new <code>audit_copy_token</code> via <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/assets/#asset_reportaudit_copycreate"><span class="InlineLink-module_text__3pIL1"><code>/asset_report/audit_copy/create</code></span></a>.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_AUDIT_COPY_TOKEN", "error_message": null, "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_INSTITUTION','The institution_id specified is invalid or does not exist.','TRUE','FALSE','<ul><li>The <code>institution_id</code> specified is invalid or does not exist.</li></ul>','<ul><li>Check the <code>institution_id</code> to ensure it is valid.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_INSTITUTION", "error_message": "invalid institution_id provided", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_LINK_CUSTOMIZATION','The Link customization is not valid for the request.','TRUE','FALSE','<ul><li>This error can happen when requesting to update account selections with a Link customization that does not enable <a href="/docs/link/customization/#account-select"><span>Account Select v2</span></a>.</li></ul>','<ul><li>Update your Link customization to enable Account Select v2 or use a Link customization with Account Select v2 enabled.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_LINK_CUSTOMIZATION", "error_message": "requested link customization is not set to update account selection", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_LINK_TOKEN','The link_token provided to initialize Link was invalid.','TRUE','FALSE','<ul><li>The <code>link_token</code> has expired. A <code>link_token</code> lasts at least 30 minutes before expiring.</li><li>The <code>link_token</code> was already used. A <code>link_token</code> can only be used once, except when working in the Sandbox test environment.</li><li>The <code>link_token</code> was created in a different environment than the one it was used with. For example, a Sandbox <code>link_token</code> was used in Production.</li><li>A user entered invalid credentials too many times during the Link flow, invalidating the <code>link_token</code>.</li></ul>','<ul><li>Confirm that the <code>link_token</code> is from the correct environment.</li><li>Generate a new <code>link_token</code> for initializing Link with and re-launch Link.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_LINK_TOKEN", "error_message": "invalid link_token provided", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_PROCESSOR_TOKEN','The processor_token provided to initialize Link was invalid.','TRUE','FALSE','<ul><li>The <code>processor_token</code> used to initialize Link was invalid.</li></ul>','<ul><li>If you are testing in Sandbox, make sure that your <code>processor_token</code> was created using the Sandbox-specific endpoint <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/sandbox/#sandboxprocessor_tokencreate"><span class="InlineLink-module_text__3pIL1"><code>/sandbox/processor_token/create</code></span></a> instead of <code>/processor_token/create</code>. Likewise, if testing in Development or Production, make sure that your <code>processor_token</code> was created using <code>/processor_token/create</code> rather than <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/sandbox/#sandboxprocessor_tokencreate"><span class="InlineLink-module_text__3pIL1"><code>/sandbox/processor_token/create</code></span></a>.</li><li>Make sure you are not using a <code>processor_token</code> created in one environment in a different environment (for example, using a Sandbox token in the Development environment).</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_PROCESSOR_TOKEN", "error_message": null, "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_PRODUCT','Your client ID does not have access to this product.','TRUE','FALSE','<ul><li>The endpoint you are trying to access must either be manually enabled for your account or requires a different pricing plan.</li><li>Your integration is using a partner endpoint integration that has not yet been enabled in the Dashboard.</li><li>Your integration is attempting to call a processor endpoint on an Item that was initialized with products that are not compatible with processor endpoints.</li></ul>','<ul><li>If you are using a partner integration, check the Dashboard <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/team/integrations" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Integrations page</span></a> to make sure it is enabled.</li><li>Update the <code>products</code> parameter in the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/tokens/#linktokencreate"><span class="InlineLink-module_text__3pIL1"><code>/link/token/create</code></span></a> call to remove any products other than <code>auth</code> or <code>identity</code>, and make sure that you are not using endpoints for products other than Balance, Auth, or Identity with this Item.</li><li><a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://plaid.com/contact" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Contact Sales</span></a> to gain access.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_PRODUCT", "error_message": "products must either be null or a list of strings containing at least one valid product", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_PRODUCTS','The pre-authenticated returning user flow was initiated with a restricted product.','FALSE','TRUE','<ul><li>For a returning user, Link was initiated with a product that is restricted from the pre-authenticated returning user flow, e.g. <code>auth</code>.</li></ul>','<ul><li>Either re-initiate the Link flow without the restricted product or contact your Plaid Account Manager to disable the pre-authenticated flow for your integration.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_PRODUCTS", "error_message": "The following products are not allowed for pre-authed items: [''auth''].", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_PUBLIC_TOKEN','','TRUE','FALSE','<ul><li>Public tokens are in the format: <code>public-&lt;environment&gt;-&lt;identifier&gt;</code></li><li>This error can happen when the <code>public_token</code> you provided is invalid, pertains to a different API environment, or has expired.</li></ul>','<ul><li>Make sure you are not using a token created in one environment in a different environment (for example, using a Sandbox token in the Development environment).</li><li>Ensure that the <code>client_id</code>, <code>secret</code>, and <code>public_token</code> are all associated with the same Plaid developer account.</li><li>The <code>public_token</code> expires after 30 minutes. If your <code>public_token</code> has expired, send your user to the Link flow to generate a new <code>public_token</code>.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_PUBLIC_TOKEN", "error_message": "could not find matching public token", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_STRIPE_ACCOUNT','The supplied Stripe account is invalidCommon causes','TRUE','FALSE','','<ul><li>See the returned <code>error_message</code>, which contains information from Stripe regarding why the account was deemed invalid.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_STRIPE_ACCOUNT", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','INVALID_WEBHOOK_VERIFICATION_KEY_ID','The key_id provided to the webhook verification endpoint was invalid.','TRUE','FALSE','<ul><li>A request was made to <a href="/docs/api/webhooks/webhook-verification/#webhook_verification_keyget"><span><code>/webhook_verification_key/get</code></span></a> using an invalid <code>key_id</code>.</li><li>The call to <a href="/docs/api/webhooks/webhook-verification/#webhook_verification_keyget"><span><code>/webhook_verification_key/get</code></span></a> was made from an environment different than the one the webhook was sent from (for example, verification of a Sandbox webhook was attempted against Production).</li></ul>','<ul><li>Ensure that the <code>key_id</code> argument provided to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/webhooks/webhook-verification/#webhook_verification_keyget"><span class="InlineLink-module_text__3pIL1"><code>/webhook_verification_key/get</code></span></a> is in fact the <code>kid</code> extracted from the JWT headers. See <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/webhooks/webhook-verification/"><span class="InlineLink-module_text__3pIL1">webhook verification</span></a> for detailed instructions.</li><li>Ensure that the webhook is being verified against the same environment as it originated from.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "INVALID_WEBHOOK_VERIFICATION_KEY_ID", "error_message": "invalid key_id provided. note that key_ids are specific to Plaid environments, and verification requests must be made to the same environment that the webhook was sent from", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','PRODUCT_UNAVAILABLE','Additional products may not be added to Items created in the pre-auth returning user flow.','TRUE','FALSE','<ul><li>A request was made to an Item created via the pre-authenticated returning user flow for a product that the Item was not initialized with during the original Link flow.</li></ul>','<ul><li>If using the pre-authenticated returning user flow, make sure to provide all the products you will be using in the <code>products</code> array at Link initialization.</li><li>If you need to use a product that is not supported by the pre-authenticated returning user flow, e.g. <code>auth</code>, contact your Plaid Account Manager to disable the pre-authenticated returning user flow for your integration.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "PRODUCT_UNAVAILABLE", "error_message": "Additional products may not be added to this pre-authed item.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','TOO_MANY_VERIFICATION_ATTEMPTS','The user attempted to verify their Manual Same-Day micro-deposit amounts more than 3 times and their Item is now permanently locked. The user must retry submitting their account information in Link.','TRUE','TRUE','<ul><li>Your user repeatedly submitted incorrect micro-deposit amounts when verifying an account via Manual Same-Day micro-deposits.</li></ul>','<ul><li>Re-initiate the Link flow and have your user attempt to verify their account again.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "TOO_MANY_VERIFICATION_ATTEMPTS", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','UNAUTHORIZED_ENVIRONMENT','Your client ID does not have access to this API environment. See which environments you are enabled for from the Dashboard.','TRUE','FALSE','<ul><li>You may not be enabled for the environment you are using.</li><li>Your code may be calling a deprecated endpoint.</li></ul>','<ul><li>Visit the Plaid <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a> to verify that you are enabled for the environment you are using.</li><li>Make sure that your code is not calling deprecated endpoints. Actively supported endpoints are listed in the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/"><span class="InlineLink-module_text__3pIL1">API reference</span></a>.</li><li>Find your API keys in the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/account/keys" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a>.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "UNAUTHORIZED_ENVIRONMENT", "error_message": "you are not authorized to create items in this api environment. Go to the Dashboard (https://dashboard.plaid.com) to see which environments you are authorized for.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','UNAUTHORIZED_ROUTE_ACCESS','Your client ID does not have access to this route.','TRUE','FALSE','<ul><li>The endpoint you are trying to access must be manually enabled for your account.</li></ul>','<ul><li><a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://plaid.com/contact" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Contact Sales</span></a> to gain access.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "UNAUTHORIZED_ROUTE_ACCESS", "error_message": "you are not authorized to access this route in this api environment.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_INPUT','USER_PERMISSION_REVOKED','The end user has revoked access to their data.','TRUE','FALSE','<ul><li>The end user revoked access to their data via the Plaid consumer portal at my.plaid.com.</li></ul>','<ul><li>Delete the item using <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemremove"><span class="InlineLink-module_text__3pIL1"><code>/item/remove</code></span></a> and prompt your user to re-enter the Link flow to re-authorize access to their data. Note that if the user re-authorizes access, a new Item will be created, and the old Item will not be re-activated.</li><li>If applicable, direct your user to a fallback, manual flow for gathering account data.</li></ul>','{ "error_type": "INVALID_INPUT", "error_code": "USER_PERMISSION_REVOKED", "error_message": "the holder of this account has revoked their permission for your application to access it", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_RESULT','LAST_UPDATED_DATETIME_OUT_OF_RANGE','No data is available from the Item within the specified date-time.','TRUE','FALSE','<ul><li><a href="/docs/api/products/balance/#accountsbalanceget"><span><code>/accounts/balance/get</code></span></a> was called with a parameter specifying the minimum acceptable data freshness, but no balance data meeting those requirements was available from the institution.</li></ul>','<ul><li>This error is not preventable by developer actions. As a workaround, you can use a cached balance from <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/accounts/#accountsget"><span class="InlineLink-module_text__3pIL1"><code>/accounts/get</code></span></a>.</li></ul>','{ "error_type": "INVALID_RESULT", "error_code": "LAST_UPDATED_DATETIME_OUT_OF_RANGE", "error_message": "requested datetime out of range, most recently updated balance 2021-01-01T00:00:00Z", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INVALID_RESULT','PLAID_DIRECT_ITEM_IMPORT_RETURNED_INVALID_MFA','The Plaid Direct Item import resulted in invalid MFA.','TRUE','FALSE','<ul><li>No known causes.</li></ul>','<ul><li>If you experience this error, contact your Plaid Account Manager or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support/new/product-and-development/product-troubleshooting/product-functionality" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">file a support ticket</span></a>.</li></ul>','{ "error_type": "INVALID_RESULT", "error_code": "PLAID_DIRECT_ITEM_IMPORT_RETURNED_INVALID_MFA", "error_message": "Plaid Direct Item Imports should not result in MFA.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','ACCOUNTS_LIMIT','Too many requests were made to the /accounts/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/accounts/#accountsget"><span><code>/accounts/get</code></span></a> in Production and Development environments are rate limited at a maximum of 15 requests per Item per minute and 15,000 per client per minute. In the Sandbox, they are are limited at a maximum of 100 per Item per minute and 5,000 per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/accounts/#accountsget"><span class="InlineLink-module_text__3pIL1"><code>/accounts/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "ACCOUNTS_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','ADDITION_LIMIT','You have exceeded your addition limit in our Development environment. To increase it, or raise it from zero, contact us.','TRUE','FALSE','<ul><li>You attempted to add more Items than currently allowed in the Development environment. The default number of Items allowed in the Development environment can be either 0 or 5, and requesting Development access can increase this number to 100.</li><li>Note that active Items are counted differently in Development than in Production. Unlike in Production, an Item in Development is counted toward the Item limit as soon as you obtain a <code>public_token</code> for it, and remains counted even if the <code>access_token</code> is removed.</li></ul>','<ul><li>Request Development access if you do not already have access to 100 Items. You can request Development access from the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/overview/development" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a>.</li><li>If you already have 100 Items, contact your Plaid Account Manager or Plaid Support to request additional Items in Development.</li><li>Test on a different environment, such as Sandbox or Production.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "ADDITION_LIMIT", "error_message": "development addition attempt limit exceeded for this client_id. contact support to increase the limit.", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','AUTH_LIMIT','Too many requests were made to the /auth/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/products/auth/#authget"><span><code>/auth/get</code></span></a> in Production and Development environments are rate limited at a maximum of 15 requests per Item per minute and 12,000 per client per minute. In the Sandbox, they are rate limited at a maximum of 100 requests per Item per minute and 500 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/auth/#authget"><span class="InlineLink-module_text__3pIL1"><code>/auth/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "AUTH_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','BALANCE_LIMIT','Too many requests were made to the /accounts/balance/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <code>/account/balance/get</code> in Production and Development environments are rate limited at a maximum of 5 requests per Item per minute and 1,200 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 25 requests per Item per minute and 100 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/balance/#accountsbalanceget"><span class="InlineLink-module_text__3pIL1"><code>/accounts/balance/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "BALANCE_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','IDENTITY_LIMIT','Too many requests were made to the /identity/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/products/identity/#identityget"><span><code>/identity/get</code></span></a> in Production and Development environments are rate limited at a maximum of 15 requests per Item per minute and 2,000 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 100 requests per Item per minute and 1,000 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/identity/#identityget"><span class="InlineLink-module_text__3pIL1"><code>/identity/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "IDENTITY_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','INSTITUTIONS_GET_LIMIT','Too many requests were made to the /institutions/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/institutions/#institutionsget"><span><code>/institutions/get</code></span></a> in Production and Development environments are rate limited at a maximum of 25 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 10 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/#institutionsget"><span class="InlineLink-module_text__3pIL1"><code>/institutions/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "INSTITUTIONS_GET_LIMIT", "error_message": "rate limit exceeded for attempts to access \"institutions get by id\". please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','INSTITUTIONS_GET_BY_ID_LIMIT','Too many requests were made to the /institutions/getbyid endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/institutions/#institutionsget_by_id"><span><code>/institutions/get_by_id</code></span></a> are rate limited at a maximum of 400 requests per client per minute. </li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/#institutionsget_by_id"><span class="InlineLink-module_text__3pIL1"><code>/institutions/get_by_id</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "INSTITUTIONS_GET_BY_ID_LIMIT", "error_message": "rate limit exceeded for attempts to access \"institutions get by id\". please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','INVESTMENT_HOLDINGS_GET_LIMIT','Too many requests were made to the /investments/holdings/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/products/investments/#investmentsholdingsget"><span><code>/investments/holdings/get</code></span></a> in Production and Development environments are rate limited at a maximum of 15 requests per Item per minute and 2,000 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 100 requests per Item per minute and 1,000 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/investments/#investmentsholdingsget"><span class="InlineLink-module_text__3pIL1"><code>/investments/holdings/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "INVESTMENT_HOLDINGS_GET_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','INVESTMENT_TRANSACTIONS_LIMIT','Too many requests were made to the /investments/transactions/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/products/investments/#investmentstransactionsget"><span><code>/investments/transactions/get</code></span></a> in Production and Development environments are rate limited at a maximum of 30 requests per Item per minute and 20,000 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 100 requests per Item per minute and 1,000 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/investments/#investmentstransactionsget"><span class="InlineLink-module_text__3pIL1"><code>/investments/transactions/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "INVESTMENT_TRANSACTIONS_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','ITEM_GET_LIMIT','Too many requests were made to the /item/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/items/#itemget"><span><code>/item/get</code></span></a> in Production and Development environments are rate limited at a maximum of 15 requests per Item per minute and 5,000 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 40 requests per Item per minute and 5,000 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemget"><span class="InlineLink-module_text__3pIL1"><code>/item/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "ITEM_GET_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','RATE_LIMIT','Too many requests were made.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time.</li><li>Sandbox credentials (the username <code>user_good</code> or <code>user_custom</code>) were used to attempt to log in to Production or Development. Because using these credentials in a live environment is a common misconfiguration, they are frequently subject to rate limiting in those environments.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to a Plaid endpoint.</li><li>Verify that you are not using Sandbox credentials in a non-Sandbox environment, such as Development or Production.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "RATE_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RATE_LIMIT_EXCEEDED','TRANSACTIONS_LIMIT','Too many requests were made to the /transactions/get endpoint.','TRUE','FALSE','<ul><li>Too many requests were made in a short period of time. Requests to <a href="/docs/api/products/transactions/#transactionsget"><span><code>/transactions/get</code></span></a> in Production and Development environments are rate limited at a maximum of 30 requests per Item per minute and 20,000 per client per minute. In the Sandbox environment, they are rate limited at a maximum of 80 requests per Item per minute and 1,000 requests per client per minute.</li></ul>','<ul><li>Check the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/logs" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">activity log</span></a> in the Dashboard to view a history of all requests made with your API keys and verify that you are not accidentally sending an excessive number of requests to <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/transactions/#transactionsget"><span class="InlineLink-module_text__3pIL1"><code>/transactions/get</code></span></a>.</li><li>If your use case requires a higher rate limit, contact your Account Manager.</li></ul>','{ "error_type": "RATE_LIMIT_EXCEEDED", "error_code": "TRANSACTIONS_LIMIT", "error_message": "rate limit exceeded for attempts to access this item. please try again later", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RECAPTCHA_ERROR','RECAPTCHA_REQUIRED','The request was flagged by Plaid''s fraud system, and requires additional verification to ensure they are not a bot.Link user experience','FALSE','TRUE','<ul><li>Plaid''s fraud system detects abusive traffic and considers a variety of parameters throughout Item creation requests. When a request is considered risky or possibly fraudulent, Link presents a reCAPTCHA for the user to solve.</li></ul>','<ul><li>Link will automatically guide your user through reCAPTCHA verification. As a general rule, we recommend instrumenting basic fraud monitoring to detect and protect your website from spam and abuse.</li><li>If your user cannot verify their session, please submit a <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support/new"target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Support</span></a> ticket with the following identifiers: <code>link_session_id</code> or <code>request_id<code>.</li></ul>','{ "error_type": "RECAPTCHA_ERROR", "error_code": "RECAPTCHA_REQUIRED", "error_message": "This request requires additional verification. Please resubmit the request after completing the challenge", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('RECAPTCHA_ERROR','RECAPTCHA_BAD','The provided challenge response was denied.Link user experience','FALSE','TRUE','<ul><li>The user was unable to successfully solve the presented reCAPTCHA problem after several attempts.</li><li>The current session is a bot or other malicious software.</li></ul>','<ul><li>Verify your user''s session -- reCAPTCHA is built to allow valid users to pass through with ease. If a user was unable to solve the challenge, they may be a bad actor.</li></ul>','{ "error_type": "RECAPTCHA_ERROR", "error_code": "RECAPTCHA_BAD", "error_message": "The provided challenge response was denied. Please try again", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('OAUTH_ERROR','INCORRECT_OAUTH_NONCE','An incorrect OAuth nonce was supplied when re-initializing Link.','TRUE','FALSE','<ul><li>During the OAuth flow, Link must be initialized, the user must be handed off to the institution''s OAuth authorization page, and then Link must be re-initialized for the user to complete Link flow. This error can occur if a different nonce is supplied during the re-initialization process than was originally supplied to Link for the first initialization step.</li></ul>','<ul><li>When re-initializing Link, make sure to use the same nonce that was used to originally initialize Link for that Item.</li></ul>','{ "error_type": "OAUTH_ERROR", "error_code": "INCORRECT_OAUTH_NONCE", "error_message": "nonce does not match", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('OAUTH_ERROR','INCORRECT_LINK_TOKEN','An incorrect Link token was supplied when re-initializing Link.','TRUE','FALSE','<ul><li>During the OAuth flow, Link must be initialized, the user must be handed off to the institution''s OAuth authorization page, and then Link must be re-initialized for the user to complete Link flow. This error can occur if a different <code>link_token</code> is supplied during the re-initialization process than was originally supplied to Link for the first initialization step.</li></ul>','<ul><li>When re-initializing Link, make sure to use the same <code>link_token</code> that was used to originally initialize Link for that Item.</li></ul>','{ "error_type": "OAUTH_ERROR", "error_code": "INCORRECT_LINK_TOKEN", "error_message": "link token does not match original link token", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('OAUTH_ERROR','OAUTH_STATE_ID_ALREADY_PROCESSED','The OAuth state has already been processed.','TRUE','TRUE','<ul><li>During the OAuth flow, Link must be initialized, the user must be handed off to the institution''s OAuth authorization page, and then Link must be re-initialized for the user to complete Link flow. This error can occur if the OAuth state ID used during re-initialization of Link has already been used.</li></ul>','<ul><li>When re-initializing Link, make sure to use a unique OAuth state ID for each Link instance.</li><li>When re-initializing Link, make sure to correctly set the <code>receivedRedirectUri</code> as described in the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://plaid.com/docs/link/oauth/#client-side-configuration" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">client-side configuration</span></a> section of the OAuth Guide. Plaid will automatically extract the OAuth state ID from the <code>receivedRedirectUri</code>.</li></ul>','{ "error_type": "OAUTH_ERROR", "error_code": "OAUTH_STATE_ID_ALREADY_PROCESSED", "error_message": null, "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('OAUTH_ERROR','OAUTH_STATE_ID_NOT_FOUND','The OAuth state id could not be found.','TRUE','FALSE','<ul><li>An internal Plaid error occurred.</li></ul>','<ul><li><a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support/new/financial-institutions/authentication-issues/oauth-issues" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">File a Plaid Support ticket</span></a>.</li></ul>','{ "error_type": "OAUTH_ERROR", "error_code": "OAUTH_STATE_ID_NOT_FOUND", "error_message": "the provided oauth_state_id wasn''t found", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_DOWN','The financial institution is down, either for maintenance or due to an infrastructure issue with their systems.Link user experience','TRUE','TRUE','<ul><li>The institution is undergoing scheduled maintenance.</li><li>The institution is experiencing temporary technical problems.</li></ul>','<ul><li>Prompt your user to retry connecting their Item in a few hours, or the following day.</li><li>Check the status of the institution via the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/status" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a> or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/#institutionsget_by_id"><span class="InlineLink-module_text__3pIL1"><code>/institutions/get_by_id</code></span></a>.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_DOWN", "error_message": "this institution is not currently responding to this request. please try again soon", "display_message": "This financial institution is not currently responding to requests. We apologize for the inconvenience.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_NOT_ENABLED_IN_ENVIRONMENT','Institution not enabled in this environmentCommon causes','TRUE','FALSE','<ul><li>You''re referencing an Institution that exists, but is not enabled for this environment (e.g calling a Sandbox endpoint with the ID of an Institution that is not enabled there).</li></ul>','','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_NOT_ENABLED_IN_ENVIRONMENT", "error_message": "Institution not enabled in this environment", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_NOT_FOUND','This institution was not found. Please check the ID supplied','TRUE','FALSE','<ul><li>A call was made using an institution_id that does not exist.</li></ul>','<ul><li>Check that the <code>institution_id</code> being used is correct.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_NOT_FOUND", "error_message": "this institution was not found. Please check the ID supplied", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_NOT_RESPONDING','The financial institution is failing to respond to some of our requests. Your user may be successful if they retry another time.Link user experience','TRUE','TRUE','<ul><li>The institution is experiencing temporary technical problems.</li></ul>','<ul><li>Prompt your user to retry connecting their Item in a few hours, or the following day.</li><li>Check the status of the institution via the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/status" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a> or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/"><span class="InlineLink-module_text__3pIL1">Institutions API</span></a>.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_NOT_RESPONDING", "error_message": "this institution is not currently responding to this request. please try again soon", "display_message": "This financial institution is not currently responding to requests. We apologize for the inconvenience.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_NOT_AVAILABLE','The financial institution is not available this time.Link user experience','TRUE','TRUE','<ul><li>Plaid‚Äôs connection to an institution is temporarily down for maintenance or other planned circumstances.</li></ul>','<ul><li>Prompt your user to retry connecting their Item in a few hours or the following day.</li><li>Check the status of the institution via the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/status" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a> or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/"><span class="InlineLink-module_text__3pIL1">API</span></a>.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_NOT_AVAILABLE", "error_message": "this institution is not currently responding to this request. please try again soon", "display_message": "This financial institution is not currently responding to requests. We apologize for the inconvenience.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_NO_LONGER_SUPPORTED','Plaid no longer supports this financial institution.Common causes','TRUE','TRUE','<ul><li>The financial institution is no longer supported on Plaid''s platform.</li><li>The institution has switched from supporting non-OAuth-based connections to requiring OAuth-based connections.</li></ul>','<ul><li>If the affected institution is Capital One, and you do not already have Production access, apply for Production access via the Plaid dashboard.</li><li>If the affected institution is Capital One and you already have Production access, refer to the migration guide provided by Plaid via email for OAuth migration instructions. If you are unable to find your migration guide, <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">contact Support</span></a>.</li><li>For other institutions, this error is un-retryable and requires custom updates from Plaid to resolve. Submit a <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support/new/financial-institutions" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Support</span></a> ticket with the failing <code>institution_id</code> for more detailed information.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_NO_LONGER_SUPPORTED", "error_message": "this institution is no longer supported", "display_message": "This financial institution is no longer supported. We apologize for the inconvenience.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','UNAUTHORIZED_INSTITUTION','You are not authorized to create Items for this institution at this time.','TRUE','FALSE','<ul><li>Access to this institution is subject to additional verification and must be manually enabled for your account.</li></ul>','<ul><li>Make sure your account is enabled for Production access.</li><li>Contact your Plaid Account Manager or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Plaid Support</span></a> for details about how to access this institution.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "UNAUTHORIZED_INSTITUTION", "error_message": "not authorized to create items for this institution", "display_message": "You are not authorized to create items for this institution at this time.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('INSTITUTION_ERROR','INSTITUTION_REGISTRATION_REQUIRED','Your application is not yet registered with the institution.','TRUE','FALSE','<ul><li>Details about your application must be registered with this institution before use.</li><li>If your account has not yet been enabled for Production access, some institutions that require registration may not be available to you.</li></ul>','<ul><li>If your account was recently enabled for Production access, please allow up to a week for registration to be completed with the institution.</li><li>If your account was enabled for Production access over a week ago, please <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/support" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">contact Support</span></a> regarding the status of your registration.</li></ul>','{ "error_type": "INSTITUTION_ERROR", "error_code": "INSTITUTION_REGISTRATION_REQUIRED", "error_message": "not yet registered to create items for this institution", "display_message": "You must register your application with this institution before you can create items for it.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('API_ERROR','INTERNAL_SERVER_ERROR','Plaid was unable to process the requestLink user experience','TRUE','TRUE','<ul><li>Plaid received an unsupported response from a financial institution, which frequently corresponds to an <a href="/docs/errors/institution/"><span>institution</span></a> error.</li><li>Plaid is experiencing internal system issues.</li><li>A product endpoint request was made for an Item at an OAuth-based institution, but the end user did not authorize the Item for the specific product, or has revoked Plaid''s access to the product. Note that for some institutions, the end user may need to specifically opt-in during the OAuth flow to share specific details, such as identity data, or account and routing number information, even if they have already opted in to sharing information about a specific account.</li></ul>','<ul><li>If the Item is at an OAuth-based institution, prompt the end user to allow Plaid to access identity data and/or account and routing number data. The end user should do this during the Link flow if they were unable to successfully complete the Link flow for the Item, or at their institution''s online banking portal if the Item has already been added.</li><li>Prompt your user to retry connecting their Item in a few hours or the following day.</li><li>Check the status of the institution via the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://dashboard.plaid.com/activity/status" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Dashboard</span></a> or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/institutions/#institutionsget_by_id"><span class="InlineLink-module_text__3pIL1"><code>/institutions/get_by_id</code></span></a>.</li></ul>','{ "error_type": "API_ERROR", "error_code": "INTERNAL_SERVER_ERROR", "error_message": "an unexpected error occurred", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('API_ERROR','PLANNED_MAINTENANCE','Plaid''s systems are undergoing maintenance and API operations are disabledLink user experience','TRUE','TRUE','<ul><li>Plaid''s systems are under maintenance and API operations are temporarily disabled. Advance notice will be provided when a maintenance window is planned.</li></ul>','<ul><li>Check Plaid''s <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="https://status.plaid.com/" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">System status</span></a> for any recent maintenance updates.</li></ul>','{ "error_type": "API_ERROR", "error_code": "PLANNED_MAINTENANCE", "error_message": "the Plaid API is temporarily unavailable due to planned maintenance. visit https://status.plaid.com/ for more information", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','PRODUCT_NOT_ENABLED','','TRUE','FALSE','<ul><li>One or more of the Items in the Asset Report was not initialized with the Assets product. Unlike some products, Assets cannot be initialized "on-the-fly" and must be initialized during the initial link process.</li></ul>','<ul><li>Make sure to include <code>assets</code> in the list of products to initialize the Item for during Link, then have your user re-link the Item.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "PRODUCT_NOT_ENABLED", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','DATA_UNAVAILABLE','','TRUE','FALSE','<ul><li>One or more of the Items in the Asset Report has experienced an error.</li></ul>','<ul><li>Check the <code>causes</code> field for a detailed breakdown of errors, then follow the troubleshooting steps for any errors found.</li><li>If the <code>causes</code> field is not present, use <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/items/#itemget"><span class="InlineLink-module_text__3pIL1"><code>/item/get</code></span></a> to query the Items in the Asset Report for errors, then follow the troubleshooting steps for any errors found.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "DATA_UNAVAILABLE", "error_message": "unable to pull sufficient data for all items to generate this report. please see the \"causes\" field for more details", "display_message": null, "causes": [  {   "display_message": null,   "error_code": "ITEM_LOGIN_REQUIRED",   "error_message": "the login details of this item have changed (credentials, MFA, or required user action) and a user login is required to update this information. use Link''s update mode to restore the item to a good state",   "error_type": "ITEM_ERROR",   "item_id": "pZ942ZA0npFEa0BgLCV9DAQv3Zq8ErIZhc81F"  } ], "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','PRODUCT_NOT_READY','','TRUE','FALSE','<ul><li><a href="/docs/api/products/assets/#asset_reportget"><span><code>/asset_report/get</code></span></a> or <a href="/docs/api/products/assets/#asset_reportpdfget"><span><code>/asset_report/pdf/get</code></span></a> was called before the Asset Report generation completed.</li></ul>','<ul><li>Listen for the <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/webhooks/#assets-product_ready"><span class="InlineLink-module_text__3pIL1"><code>PRODUCT_READY</code></span></a> webhook and wait to call <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/assets/#asset_reportget"><span class="InlineLink-module_text__3pIL1"><code>/asset_report/get</code></span></a> or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/assets/#asset_reportpdfget"><span class="InlineLink-module_text__3pIL1"><code>/asset_report/pdf/get</code></span></a> until that webhook has been fired.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "PRODUCT_NOT_READY", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','ASSET_REPORT_GENERATION_FAILED','','TRUE','FALSE','<ul><li>Plaid is experiencing temporary difficulties generating Asset Reports.</li></ul>','<ul><li>Try creating the Asset Report again later.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "ASSET_REPORT_GENERATION_FAILED", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','INVALID_PARENT','Common causes','TRUE','FALSE','<ul><li>An endpoint that creates a copy or modified copy of an Asset Report (such as <a href="/docs/api/products/assets/#asset_reportfilter"><span><code>/asset_report/filter</code></span></a> or <a href="/docs/api/products/assets/#asset_reportaudit_copycreate"><span><code>/asset_report/audit_copy/create</code></span></a>) was called, but the original Asset Report does not exist, either because it was never successfully created in the first place or because it was deleted.</li></ul>','<ul><li>Re-create the original Asset Report and re-try the endpoint call on the new Asset Report.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "INVALID_PARENT", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','INSIGHTS_NOT_ENABLED','Common causes','TRUE','FALSE','<ul><li><a href="/docs/api/products/assets/#asset_reportget"><span><code>/asset_report/get</code></span></a> or <a href="/docs/api/products/assets/#asset_reportpdfget"><span><code>/asset_report/pdf/get</code></span></a> was called with <code>enable_insights</code> set to <code>true</code> by a Plaid developer account that has not been enabled for access to Asset Reports with Insights.</li></ul>','<ul><li><a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="http://plaid.com/contact" target="_blank" rel="nofollow noopener noreferrer"><span class="InlineLink-module_text__3pIL1">Contact sales</span></a> to enable Asset Reports with Insights for your account.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "INSIGHTS_NOT_ENABLED", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('ASSET_REPORT_ERROR','INSIGHTS_PREVIOUSLY_NOT_ENABLED','Common causes','TRUE','FALSE','<ul><li><a href="/docs/api/products/assets/#asset_reportget"><span><code>/asset_report/get</code></span></a> or <a href="/docs/api/products/assets/#asset_reportpdfget"><span><code>/asset_report/pdf/get</code></span></a> was called with <code>enable_insights</code> set to <code>true</code> by a Plaid developer account that is currently enabled for Asset Reports with Insights, but was not enabled at the time that the report was created.</li></ul>','<ul><li>Re-create the Asset Report with <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/assets/#asset_reportcreate"><span class="InlineLink-module_text__3pIL1"><code>/asset_report/create</code></span></a> and then fetch the new Asset Report.</li></ul>','{ "error_type": "ASSET_REPORT_ERROR", "error_code": "INSIGHTS_PREVIOUSLY_NOT_ENABLED", "error_message": "", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_BLOCKED','The payment was blocked for violating compliance rules.','TRUE','FALSE','<ul><li>The payment amount value when calling <a href="/docs/api/products/payment-initiation/#payment_initiationpaymentcreate"><span><code>/payment_initiation/payment/create</code></span></a> was too high.</li><li>Too many payments were created in a short period of time.</li></ul>','<ul><li>Try again with a lower payment amount value.</li><li>Contact your Plaid Account Manager for your compliance rules.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_BLOCKED", "error_message": "payment blocked", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_CANCELLED','The payment was cancelled.','FALSE','TRUE','<ul><li>The payment was cancelled by the user during the authorisation process</li></ul>','<ul><li>Try again or choose another institution to initiate a payment.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_CANCELLED", "error_message": "user cancelled the payment", "display_message": "Try making your payment again or select a different bank to continue.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_INSUFFICIENT_FUNDS','The account has insufficient funds to complete the payment.','FALSE','TRUE','<ul><li>The account selected has insufficient funds to complete the payment.</li></ul>','<ul><li>Try again with a lower payment amount value.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_INSUFFICIENT_FUNDS", "error_message": "insufficient funds to complete the request", "display_message": "There isn''t enough money in this account to complete the payment. Try again, or select another account or bank.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_INVALID_RECIPIENT','The recipient was rejected by the chosen institution.','FALSE','TRUE','<ul><li>The recipient name is too long or contains special characters.</li><li>The address is too long or contains special characters.</li><li>The account number is invalid.</li></ul>','<ul><li>Try again with a different recipient.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_INVALID_RECIPIENT", "error_message": "payment recipient invalid", "display_message": "The payment recipient is invalid for the selected institution. Create a new payment with a different recipient.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_INVALID_REFERENCE','The reference was rejected by the chosen institution.','FALSE','TRUE','<ul><li>The reference is too long or contains special characters.</li></ul>','<ul><li>Try again with a different reference.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_INVALID_REFERENCE", "error_message": "payment reference invalid", "display_message": "The payment reference is invalid for the selected institution. Create a new payment with a different reference.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_INVALID_SCHEDULE','The schedule was rejected by the chosen institution.','FALSE','TRUE','<ul><li>The chosen institution does not support negative payment execution days.</li><li>The first payment date is a holiday or on a weekend.</li></ul>','<ul><li>Try again with a different schedule.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_INVALID_SCHEDULE", "error_message": "payment schedule invalid", "display_message": "The payment schedule is invalid for the selected institution. Create a new payment with a different schedule.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_REJECTED','The payment was rejected by the chosen institution.','FALSE','TRUE','<ul><li>The amount was too large.</li><li>The payment was considered suspicious by the institution.</li></ul>','<ul><li>Try again with different payment parameters.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_REJECTED", "error_message": "payment rejected", "display_message": "The payment was rejected by the institution. Try again, or select another account or bank.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('PAYMENT_ERROR','PAYMENT_SCHEME_NOT_SUPPORTED','The requested payment scheme is not supported by the chosen institution.','FALSE','TRUE','<ul><li>The payment scheme when calling <a href="/docs/api/products/payment-initiation/#payment_initiationpaymentcreate"><span><code>/payment_initiation/payment/create</code></span></a> is not suported by institution.</li><li>Scheme automatic downgrade failed.</li></ul>','<ul><li>Try again with different payment scheme.</li><li>Try again with different institution.</li></ul>','{ "error_type": "PAYMENT_ERROR", "error_code": "PAYMENT_SCHEME_NOT_SUPPORTED", "error_message": "payment scheme not supported", "display_message": "The payment scheme is not supported by the institution. Either change scheme or select another institution.", "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_LIMIT_EXCEEDED','The attempted transfer exceeded the account''s daily transfer or single transfer limits.','TRUE','FALSE','<ul><li>The attempted transfer exceeded the account''s daily transfer or single transfer limits. The error message will indicate which transfer limit was exceeded.</li></ul>','<ul><li>If the limit exceeded was a daily limit, and your use case allows it, retry the transfer again later.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_LIMIT_EXCEEDED", "error_message": "transfer limit exceeded", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_MISSING_ORIGINATION_ACCOUNT','There are multiple origination accounts available for the transfer, but which account to use was not specified.','TRUE','FALSE','<ul><li>There is more than one origination account associated with the client id, but no account was specified in the request.</li></ul>','<ul><li>Make sure to specify an <code>origination_account_id</code> when calling <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/transfer/#transfercreate"><span class="InlineLink-module_text__3pIL1"><code>/transfer/create</code></span></a> or <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/transfer/#transferauthorizationcreate"><span class="InlineLink-module_text__3pIL1"><code>/transfer/authorization/create</code></span></a>.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_MISSING_ORIGINATION_ACCOUNT", "error_message": "origination_account_id is required", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_INVALID_ORIGINATION_ACCOUNT','The origination account specified for the transfer was invalid.','TRUE','FALSE','<ul><li>The <code>origination_account_id</code> specified when calling <a href="/docs/api/products/transfer/#transfercreate"><span><code>/transfer/create</code></span></a> or <a href="/docs/api/products/transfer/#transferauthorizationcreate"><span><code>/transfer/authorization/create</code></span></a> was invalid.</li></ul>','<ul><li>Ensure that the <code>origination_account_id</code> you are using corresponds to a valid origination account owned by you. You can obtain your <code>origination_account_id</code> from your Plaid Account Manager.</li><li>Ensure that the casing matches, as all Plaid identifiers are case-sensitive.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_INVALID_ORIGINATION_ACCOUNT", "error_message": "origination_account_id is invalid", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_ACCOUNT_BLOCKED','The transfer could not be completed because a previous transfer involving the same end-user account resulted in an error.','TRUE','FALSE','<ul><li>Plaid has flagged the end-user''s account as not valid for use with Transfer.</li></ul>','<ul><li>Ask the end-user to link a different account with Plaid and re-attempt the transfer with the new account.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_ACCOUNT_BLOCKED", "error_message": "transfer was blocked due to a previous ACH return on this account", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_NOT_CANCELLABLE','The transfer could not be canceled.','TRUE','FALSE','<ul><li>An attempt was made to cancel a transfer that has already been sent to the network for execution and cannot be cancelled at this stage.</li></ul>','<ul><li>Use an endpoint such as <a class="Touchable-module_resetButtonOrLink__hwe7O InlineLink-module_inlinelink__3SEIo" href="/docs/api/products/transfer/#transferget"><span class="InlineLink-module_text__3pIL1"><code>/transfer/get</code></span></a> to check the value of the <code>cancellable</code> property before canceling a transfer.</li><li>If applicable, contact the counterparty to the transfer and ask them to return the funds after the transfer has executed.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_NOT_CANCELLABLE", "error_message": "transfer is not cancellable", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_UNSUPPORTED_ACCOUNT_TYPE','An attempt was made to transfer funds to or from an unsupported account type.','TRUE','FALSE','<ul><li>An attempt was made to transfer funds to or from an unsupported account type. Only checking and savings accounts can be used with Transfer. In addition, if the transfer is a debit transfer, the account must be a debitable account.</li></ul>','<ul><li>Ask the user to link a different account to use with Transfer.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_UNSUPPORTED_ACCOUNT_TYPE", "error_message": "transfer account type not supported", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message'),
('TRANSFER_ERROR','TRANSFER_FORBIDDEN_ACH_CLASS','An attempt was made create a transfer with a forbidden ACH class (SEC code).','TRUE','FALSE','<ul><li><p>Your Plaid account has not been enabled for the ACH class specified in the request.</p></li><li><p>The ACH class specified in the transfer request was incorrect.</p></li></ul>','<ul><li>Verify that the ACH class in the request is correct.</li><li>If you have not already done so, contact your Plaid Account Manager to request that the desired ACH class be enabled for your account.</li></ul>','{ "error_type": "TRANSFER_ERROR", "error_code": "TRANSFER_FORBIDDEN_ACH_CLASS", "error_message": "specified ach_class is forbidden", "display_message": null, "request_id": "HNTDNrA8F1shFEW"}','need friendly message');



DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
  alpha_3 citext PRIMARY KEY,
  alpha_2 citext,
  name citext NOT NULL
);

insert into countries(alpha_3, alpha_2, "name") values
('afg','af','Afghanistan'),
('alb','al','Albania'),
('dza','dz','Algeria'),
('and','ad','Andorra'),
('ago','ao','Angola'),
('atg','ag','Antigua and Barbuda'),
('arg','ar','Argentina'),
('arm','am','Armenia'),
('aus','au','Australia'),
('aut','at','Austria'),
('aze','az','Azerbaijan'),
('bhs','bs','Bahamas'),
('bhr','bh','Bahrain'),
('bgd','bd','Bangladesh'),
('brb','bb','Barbados'),
('blr','by','Belarus'),
('bel','be','Belgium'),
('blz','bz','Belize'),
('ben','bj','Benin'),
('btn','bt','Bhutan'),
('bol','bo','Bolivia (Plurinational State of)'),
('bih','ba','Bosnia and Herzegovina'),
('bwa','bw','Botswana'),
('bra','br','Brazil'),
('brn','bn','Brunei Darussalam'),
('bgr','bg','Bulgaria'),
('bfa','bf','Burkina Faso'),
('bdi','bi','Burundi'),
('cpv','cv','Cabo Verde'),
('khm','kh','Cambodia'),
('cmr','cm','Cameroon'),
('can','ca','Canada'),
('caf','cf','Central African Republic'),
('tcd','td','Chad'),
('chl','cl','Chile'),
('chn','cn','China'),
('col','co','Colombia'),
('com','km','Comoros'),
('cog','cg','Congo'),
('cod','cd','Congo, Democratic Republic of the'),
('cri','cr','Costa Rica'),
('civ','ci','C√¥te d''Ivoire'),
('hrv','hr','Croatia'),
('cub','cu','Cuba'),
('cyp','cy','Cyprus'),
('cze','cz','Czechia'),
('dnk','dk','Denmark'),
('dji','dj','Djibouti'),
('dma','dm','Dominica'),
('dom','do','Dominican Republic'),
('ecu','ec','Ecuador'),
('egy','eg','Egypt'),
('slv','sv','El Salvador'),
('gnq','gq','Equatorial Guinea'),
('eri','er','Eritrea'),
('est','ee','Estonia'),
('swz','sz','Eswatini'),
('eth','et','Ethiopia'),
('fji','fj','Fiji'),
('fin','fi','Finland'),
('fra','fr','France'),
('gab','ga','Gabon'),
('gmb','gm','Gambia'),
('geo','ge','Georgia'),
('deu','de','Germany'),
('gha','gh','Ghana'),
('grc','gr','Greece'),
('grd','gd','Grenada'),
('gtm','gt','Guatemala'),
('gin','gn','Guinea'),
('gnb','gw','Guinea-Bissau'),
('guy','gy','Guyana'),
('hti','ht','Haiti'),
('hnd','hn','Honduras'),
('hun','hu','Hungary'),
('isl','is','Iceland'),
('ind','in','India'),
('idn','id','Indonesia'),
('irn','ir','Iran (Islamic Republic of)'),
('irq','iq','Iraq'),
('irl','ie','Ireland'),
('isr','il','Israel'),
('ita','it','Italy'),
('jam','jm','Jamaica'),
('jpn','jp','Japan'),
('jor','jo','Jordan'),
('kaz','kz','Kazakhstan'),
('ken','ke','Kenya'),
('kir','ki','Kiribati'),
('prk','kp','Korea (Democratic People''s Republic of)'),
('kor','kr','Korea, Republic of'),
('kwt','kw','Kuwait'),
('kgz','kg','Kyrgyzstan'),
('lao','la','Lao People''s Democratic Republic'),
('lva','lv','Latvia'),
('lbn','lb','Lebanon'),
('lso','ls','Lesotho'),
('lbr','lr','Liberia'),
('lby','ly','Libya'),
('lie','li','Liechtenstein'),
('ltu','lt','Lithuania'),
('lux','lu','Luxembourg'),
('mdg','mg','Madagascar'),
('mwi','mw','Malawi'),
('mys','my','Malaysia'),
('mdv','mv','Maldives'),
('mli','ml','Mali'),
('mlt','mt','Malta'),
('mhl','mh','Marshall Islands'),
('mrt','mr','Mauritania'),
('mus','mu','Mauritius'),
('mex','mx','Mexico'),
('fsm','fm','Micronesia (Federated States of)'),
('mda','md','Moldova, Republic of'),
('mco','mc','Monaco'),
('mng','mn','Mongolia'),
('mne','me','Montenegro'),
('mar','ma','Morocco'),
('moz','mz','Mozambique'),
('mmr','mm','Myanmar'),
('nam','na','Namibia'),
('nru','nr','Nauru'),
('npl','np','Nepal'),
('nld','nl','Netherlands'),
('nzl','nz','New Zealand'),
('nic','ni','Nicaragua'),
('ner','ne','Niger'),
('nga','ng','Nigeria'),
('mkd','mk','North Macedonia'),
('nor','no','Norway'),
('omn','om','Oman'),
('pak','pk','Pakistan'),
('plw','pw','Palau'),
('pan','pa','Panama'),
('png','pg','Papua New Guinea'),
('pry','py','Paraguay'),
('per','pe','Peru'),
('phl','ph','Philippines'),
('pol','pl','Poland'),
('prt','pt','Portugal'),
('qat','qa','Qatar'),
('rou','ro','Romania'),
('rus','ru','Russian Federation'),
('rwa','rw','Rwanda'),
('kna','kn','Saint Kitts and Nevis'),
('lca','lc','Saint Lucia'),
('vct','vc','Saint Vincent and the Grenadines'),
('wsm','ws','Samoa'),
('smr','sm','San Marino'),
('stp','st','Sao Tome and Principe'),
('sau','sa','Saudi Arabia'),
('sen','sn','Senegal'),
('srb','rs','Serbia'),
('syc','sc','Seychelles'),
('sle','sl','Sierra Leone'),
('sgp','sg','Singapore'),
('svk','sk','Slovakia'),
('svn','si','Slovenia'),
('slb','sb','Solomon Islands'),
('som','so','Somalia'),
('zaf','za','South Africa'),
('ssd','ss','South Sudan'),
('esp','es','Spain'),
('lka','lk','Sri Lanka'),
('sdn','sd','Sudan'),
('sur','sr','Suriname'),
('swe','se','Sweden'),
('che','ch','Switzerland'),
('syr','sy','Syrian Arab Republic'),
('tjk','tj','Tajikistan'),
('tza','tz','Tanzania, United Republic of'),
('tha','th','Thailand'),
('tls','tl','Timor-Leste'),
('tgo','tg','Togo'),
('ton','to','Tonga'),
('tto','tt','Trinidad and Tobago'),
('tun','tn','Tunisia'),
('tur','tr','Turkey'),
('tkm','tm','Turkmenistan'),
('tuv','tv','Tuvalu'),
('uga','ug','Uganda'),
('ukr','ua','Ukraine'),
('are','ae','United Arab Emirates'),
('gbr','gb','United Kingdom of Great Britain and Northern Ireland'),
('usa','us','United States of America'),
('ury','uy','Uruguay'),
('uzb','uz','Uzbekistan'),
('vut','vu','Vanuatu'),
('ven','ve','Venezuela (Bolivarian Republic of)'),
('vnm','vn','Viet Nam'),
('yem','ye','Yemen'),
('zmb','zm','Zambia'),
('zwe','zw','Zimbabwe');

create unique index countries_alpha_2_uidx on countries(alpha_2);

drop table if exists account_types;

create table account_types (
  account_type citext PRIMARY KEY,
  description citext NOT NULL
);

insert into account_types(account_type,description) values
('depository', 'An account type holding cash, in which funds are deposited. Supported products for depository accounts are: Auth (checking and savings types only), Balance, Transactions, Identity, Payment Initiation, and Assets.'),
('credit','A credit card type account. Supported products for credit accounts are: Balance, Transactions, Identity, and Liabilities.'),
('loan','A loan type account. Supported products for loan accounts are: Balance, Liabilities, and Transactions.'),
('investment','An investment account. Supported products for investment accounts are: Balance and Investments. In API versions 2018-05-22 and earlier, this type is called brokerage.'),
('other','Other or unknown account type. Supported products for other accounts are: Balance, Transactions, Identity, and Assets.');


DROP TABLE IF EXISTS account_subtypes;

CREATE TABLE account_subtypes (
  id serial PRIMARY KEY,
  account_type citext REFERENCES account_types(account_type) ON DELETE CASCADE ON UPDATE CASCADE,       
  account_subtype citext not null, 
  description citext NOT NULL,
  country citext REFERENCES countries(alpha_3) ON DELETE CASCADE ON UPDATE CASCADE
);

create unique index account_subtypes_uidx on account_subtypes(account_type,account_subtype);

insert into account_subtypes(account_subtype,account_type,description,country) values
('checking','depository','Checking account','usa'),
('savings','depository','Savings account',null),
('has','depository','Health Savings Account (US only) that can only hold cash',null),
('cd','depository','Certificate of deposit account',null),
('money market','depository','Money market account',null),
('paypal','depository','PayPal depository account',null),
('prepaid','depository','Prepaid debit card',null),
('cash management','depository','A cash management account, typically a cash account at a brokerage',null),
('ebt','depository','An Electronic Benefit Transfer (EBT) account, used by certain public assistance programs to distribute funds','usa'),
('credit card','credit','Bank-issued credit card',null),
('paypal','credit','PayPal-issued credit card',null),
('auto','loan','Auto loan',null),
('business','loan','Business loan',null),
('commercial','loan','Commercial loan',null),
('construction','loan','Construction loan',null),
('consumer','loan','Consumer loan',null),
('home equity','loan','Home Equity Line of Credit (HELOC)',null),
('loan','loan','General loan',null),
('mortgage','loan','Mortgage loan',null),
('overdraft','loan','Pre-approved overdraft account, usually tied to a checking account',null),
('line of credit','loan','Pre-approved line of credit',null),
('student','loan','Student loan',null),
('other','loan','Other loan type or unknown loan type',null),
('529','investment','Tax-advantaged college savings and prepaid tuition 529 plans','usa'),
('401a','investment','Employer-sponsored money-purchase 401(a) retirement plan','usa'),
('401k','investment','Standard 401(k) retirement account','usa'),
('403B','investment','Retirement savings account for non-profits and schools ','usa'),
('457b','investment','Tax-advantaged deferred-compensation 457(b) retirement plan for governments and non-profits','usa'),
('brokerage','investment','Standard brokerage account',null),
('cash isa','investment','Individual Savings Account (ISA) that pays interest tax-free','gbr'),
('education savings account','investment','Tax-advantaged Coverdell Education Savings Account ','usa'),
('fixed annuity','investment','Fixed annuity',null),
('gic','investment','Guaranteed Investment Certificate ','can'),
('health reimbursement arrangement','investment','Tax-advantaged Health Reimbursement Arrangement (HRA) benefit plan','usa'),
('has','investment','Non-cash tax-advantaged medical Health Savings Account (HSA)','usa'),
('ira','investment','Traditional Invididual Retirement Account (IRA)','usa'),
('isa','investment','Non-cash Individual Savings Account (ISA)','gbr'),
('keogh','investment','Keogh self-employed retirement plan','usa'),
('lif','investment','Life Income Fund (LIF) retirement account','can'),
('life insurance','investment','Life insurance account',null),
('lira','investment','Locked-in Retirement Account (LIRA)','can'),
('lrif','investment','Locked-in Retirement Income Fund (LRIF)','can'),
('lrsp','investment','Locked-in Retirement Savings Plan','can'),
('mutual fund','investment','Mutual fund account',null),
('non-taxable brokerage account','investment','A non-taxable brokerage account that is not covered by a more specific subtype',null),
('other','investment','An account whose type could not be determined',null),
('other annuity','investment','An annuity account not covered by other subtypes',null),
('other insurance','investment','An insurance account not covered by other subtypes',null),
('pension','investment','Standard pension account',null),
('prif','investment','Prescribed Registered Retirement Income Fund','can'),
('profit sharing plan','investment','Plan that gives employees share of company profits',null),
('qshr','investment','Qualifying share account',null),
('rdsp','investment','Registered Disability Savings Plan (RSDP)','can'),
('resp','investment','Registered Education Savings Plan','can'),
('retirement','investment','Retirement account not covered by other subtypes',null),
('rlif','investment','Restricted Life Income Fund (RLIF)','can'),
('roth','investment','Roth IRA','usa'),
('roth 401k','investment','Employer-sponsored Roth 401(k) plan','usa'),
('rrif','investment','Registered Retirement Income Fund (RRIF)','can'),
('rrsp','investment','Registered Retirement Savings Plan','can'),
('sarsep','investment','Salary Reduction Simplified Employee Pension Plan (SARSEP), discontinued retirement plan','usa'),
('sep ira','investment','Simplified Employee Pension IRA, retirement plan for small businesses and self-employed','usa'),
('simple ira','investment','Savings Incentive Match Plan for Employees IRA, retirement plan for small businesses',null),
('sipp','investment','Self-Invested Personal Pension (SIPP)','gbr'),
('stock plan','investment','Standard stock plan account',null),
('tfsa','investment','Tax-Free Savings Account ','can'),
('trust','investment','Account representing funds or assets held by a trustee for the benefit of a beneficiary. Includes both revocable and irrevocable trusts.',null),
('ugma','investment','Uniform Gift to Minors Act (brokerage account for minors)','usa'),
('utma','investment','Uniform Transfers to Minors Act (brokerage account for minors)',null),
('variable annuity','investment','Tax-deferred capital accumulation annuity contract',null),
('other','other','Other or unknown account type. Supported products for other accounts are: Balance, Transactions, Identity, and Assets.',null)
;

/************************************************************************************************************
users
************************************************************************************************************/

CREATE TABLE IF NOT EXISTS users
(
  id SERIAL PRIMARY KEY,
  email citext UNIQUE NOT NULL,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);


/************************************************************************************************************
institutions
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS institutions
(
    id text PRIMARY KEY,
    name citext NOT NULL,
    url citext,
    primary_color citext,
    logo citext,
    jsonDoc jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_institutions
(
    item_id text NOT NULL PRIMARY KEY,
    user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
    institution_id text REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    access_token text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


/************************************************************************************************************
accounts
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS accounts
(
    id text PRIMARY KEY,
    name citext NOT NULL,
    mask citext NOT NULL,
    official_name citext,
    current_balance numeric(28,10),
    available_balance numeric(28,10),
    iso_currency_code citext,
    account_limit numeric(28,10),
    type citext NOT NULL,
    subtype citext NOT NULL,
    last_import_date  timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
    institution_id citext REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type, subtype) REFERENCES account_subtypes (account_type, account_subtype)
);


/************************************************************************************************************
transactions
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS transactions
(
    id text PRIMARY KEY,
    user_id integer references users(id) on delete cascade on update cascade NOT NULL,    
    account_id citext references accounts(id) on delete cascade on update cascade NOT NULL,
    amount numeric(28,10) default 0,
    iso_currency_code citext,
    imported_category_id citext,
    imported_category citext,
    imported_subcategory citext,
    imported_name citext,
    category citext,
    subcategory citext,
    name citext,
    check_number citext,
    date date,
    month integer GENERATED ALWAYS AS (date_part('month', date)) STORED,
    year integer GENERATED ALWAYS AS (date_part('year', date)) STORED,
    authorized_date date,
    address citext,
    city citext,
    region citext,
    postal_code citext,
    country citext,
    lat double precision,
    lon double precision,
    store_number citext,
    merchant_name citext,
    payment_channel citext,
    is_pending boolean default false,
    type citext,
    transaction_code citext,
    is_recurring boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


create or replace function apply_transactions_rules() 
  returns trigger 
 language plpgsql
 as $$
  declare
    record_count integer;
    statements record;
  begin
    
    select count(*) 
      from affected_rows 
      into record_count;

    for statements in        
        select format( 'update %I set %s where user_id=%s and %s;'
                       , 'transactions' -- ur.rule->>'tablename'
                       , set_columns.cols
                       , user_id
                       , where_columns.cols
                       ) as statement
            from user_rules ur
            cross join lateral (
                  select string_agg(quote_ident(col->>'name') || '=' || '' ||  quote_literal(col->>'value'), ', ') AS cols
                    from jsonb_array_elements(ur.rule->'set') col
                  ) set_columns
            cross join lateral (
                  select string_agg(quote_ident(col->>'name') || ' ' 
                                    || case (col->>'condition')::citext when 'equals' then '=' else 'like 'end 
                                    || '' 
                                    || 
                                   case (col->>'condition')::citext
                                   when 'equals' then quote_literal(col->>'value')
                                   when 'starts with' then quote_literal(col->>'value'||'%')
                                   when 'ends with' then quote_literal( format('%s%s', '%',col->>'value' )  )
                                   else 'like'
                                    end
                                   , ' and ') AS cols
                    from jsonb_array_elements(ur.rule->'where') col
                  ) where_columns
            where user_id in (select user_id from affected_rows)
      loop 
      -- raise notice '%', statements.statement;
      execute (statements.statement);  
      end loop;

    -- raise notice 'affected %:%', TG_OP, record_count;

    return null;   
  end
$$;

create or replace trigger transactions_insert_trigger
 after insert on transactions
 REFERENCING NEW TABLE AS affected_rows
   FOR EACH STATEMENT 
   WHEN (pg_trigger_depth() < 1)
   execute procedure apply_transactions_rules();


create or replace trigger transactions_update_trigger
 after update on transactions
 REFERENCING OLD TABLE AS affected_rows  
   FOR EACH STATEMENT 
   WHEN (pg_trigger_depth() < 1)
   execute procedure apply_transactions_rules();


-- CREATE OR REPLACE FUNCTION set_transaction_values() RETURNS trigger AS $$
--   BEGIN
--     NEW.imported_category :=COALESCE(NEW.imported_category,'General');
--     NEW.imported_subcategory :=COALESCE(NEW.imported_subcategory,'General');
--     RETURN NEW;
--   END
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER transactions_set_transaction_values
-- after insert or update on transactions
-- FOR EACH ROW EXECUTE PROCEDURE set_transaction_values();


/************************************************************************************************************
categories
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS categories
(
  id serial PRIMARY KEY,
  category_id citext,
  category citext not null,
  subcategory citext
);

--
CREATE UNIQUE INDEX categories_uidx ON categories(category, subcategory, source);;
-- unique index to not allow more than one null on subcategory
CREATE UNIQUE INDEX categories_null_uidx ON categories (source, category, (subcategory IS NULL)) WHERE subcategory IS NULL;


CREATE TABLE IF NOT EXISTS user_categories
(
  id SERIAL PRIMARY KEY,
  user_id integer references users(id) on delete cascade on update cascade,
  user_category citext,
  user_subcategory citext,
  min_budgeted_amount numeric(28,10) default 0,
  max_budgeted_amount numeric(28,10) default 0,
  do_not_budget boolean default false
);
-- unique index to not allow more than one null on user_subcategory
create unique index user_categories_uidx  on user_categories (user_id, user_category, (user_subcategory is null)) WHERE user_subcategory is null;
create unique index user_categories_uidx2 on user_categories (user_id, user_category, user_subcategory);  

create or replace function user_category_update_values() returns trigger AS $$
  begin

	update transactions t
		   set category = subquery.user_category,
			   subcategory = subquery.user_subcategory
	  from (select c.category, c.subcategory, uc.user_category, uc.user_subcategory
			  from user_categories uc
			 inner join categories c on c.id = category_id
			 where user_id = new.user_id
			   and category_id = new.category_id) subquery
	 where t.imported_category = subquery.category
	   and t.imported_subcategory = subquery.subcategory;   
	   
    return new;
  end
$$ LANGUAGE plpgsql;

create or replace trigger user_category_update_trigger
 after update on user_categories
   for each row execute procedure user_category_update_values();


    

/************************************************************************************************************
user rules
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS user_rules
(
  id SERIAL PRIMARY KEY,
  user_id integer references users(id) on delete cascade on update cascade,
  rule jsonb,
  created_at timestamptz default now()
); 
CREATE UNIQUE INDEX user_rules_uidx ON user_rules(user_id,rule);

-- -- starts with
-- select * from transactions
-- where imported_name ~* '^grub.*$';

-- -- ends with
-- select * from transactions
-- where imported_name ~* '.*pharmacy$'

-- -- contains
-- select * from transactions
-- where imported_name ~* '.*life.*$'

-- --equals
-- select * from transactions
-- where imported_name ~* '^COSERV ELECTRIC$'

/************************************************************************************************************
helper functions
************************************************************************************************************/
create or replace function months_between (startDate timestamp, endDate timestamp)
returns integer as 
$$
select ((extract('years' from $2)::int -  extract('years' from $1)::int) * 12) 
    - extract('month' from $1)::int + extract('month' from $2)::int
$$ 
LANGUAGE SQL
immutable
returns NULL on NULL input;

create or replace function end_of_month(date)
returns date as
$$
select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date;
$$ 
language SQL
immutable strict;



/************************************************************************************************************
PLAID webook tables
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS plaid_webhook_history
(
  id SERIAL PRIMARY KEY,
  item_id text NOT NULL,
  webhook_code citext NOT NULL,
  webhook_type citext NOT NULL,
  error jsonb,
  jsonDoc jsonb NOT NULL,
  created_at timestamptz default now()
);


CREATE TABLE IF NOT EXISTS plaid_webhook_history_data
(
  id SERIAL PRIMARY KEY,
  plaid_webhook_history_id integer REFERENCES plaid_webhook_history(id) ON DELETE CASCADE ON UPDATE CASCADE,
  user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
  institution_id text REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
  jsonDoc jsonb NOT NULL,  
  importError jsonb,
  imported_at timestamptz,
  created_at timestamptz default now()    
);



/************************************************************************************************************
PLAID webook account processing
************************************************************************************************************/
CREATE OR REPLACE FUNCTION plaid_insert_or_update_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin

    insert into accounts(
          id
        , user_id
        , name
        , mask
        , official_name
        , type
        , subtype
        , available_balance
        , current_balance
        , account_limit
        , iso_currency_code
        , institution_id
    )
    select account->>'account_id' "id"
         , user_id
         , account->>'name' "name"	 
         , account->>'mask' "mask"
         , account->>'official_name' "official_name"		 
         , account->>'type' "type"
         , account->>'subtype' "subtype"
         , (account->'balances'->>'available')::numeric(28,4) "available_balance"
         , (account->'balances'->>'current')::numeric(28,4) "current_balance"	   
         , (account->'balances'->>'limit')::numeric(28,4) "account_limit"	 
         , account->'balances'->>'iso_currency_code' "iso_currency_code"
         , institution_id
    from(
        select user_id, institution_id, jsonb_array_elements(jsondoc->'accounts') "account"
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as accounts
    ON CONFLICT (ID)
    DO UPDATE SET
    official_name = excluded.official_name,
    subtype = excluded.subtype,
    type = excluded.type,
    available_balance = excluded.available_balance,
    current_balance = excluded.current_balance,
    account_limit = excluded.account_limit,
    iso_currency_code = excluded.iso_currency_code;

  end;
$BODY$;

/************************************************************************************************************
PLAID webook category processing
************************************************************************************************************/
CREATE OR REPLACE FUNCTION plaid_insert_or_update_categories(webhookHistoryId integer)
RETURNS void
AS $$
BEGIN

  insert into categories(category, subcategory, source)
  select coalesce(transaction->'category'->>0, 'Unassigned') as category
       , coalesce(transaction->'category'->>1, 'Unassigned') as subcategory
       , 'Plaid' as source
   from  (
         select user_id, institution_id, jsonb_array_elements(jsondoc->'transactions') "transaction"
           from plaid_webhook_history_data
          where plaid_webhook_history_id = webhookHistoryId
       ) as transactions  
      on conflict do nothing; 

END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION plaid_insert_or_update_user_categories(webhookHistoryId integer)
RETURNS void
AS $$
BEGIN

  insert into user_categories(user_id, user_category, user_subcategory)
  select user_id
       , coalesce(transaction->'category'->>0, 'Unassigned') as category
       , coalesce(transaction->'category'->>1, 'Unassigned') as subcategory
   from  (
         select user_id, institution_id, jsonb_array_elements(jsondoc->'transactions') "transaction"
           from plaid_webhook_history_data
          where plaid_webhook_history_id = webhookHistoryId
       ) as transactions
   where not exists (
         select 1 
           from user_categories uc
          where user_category = transaction->'category'->>0 
            and user_subcategory = transaction->'category'->>1
            and uc.user_id=transactions.user_id
		)
      on conflict do nothing;

END; $$ 
LANGUAGE 'plpgsql';


/************************************************************************************************************
PLAID webook transaction processing
************************************************************************************************************/
CREATE OR REPLACE FUNCTION plaid_insert_or_update_transactions(webhookHistoryId integer)
 RETURNS void 
 LANGUAGE 'plpgsql' 
 COST 100 
 VOLATILE 
 PARALLEL 
 UNSAFE 
AS $BODY$
BEGIN

    insert into transactions(
           id
         , user_id
         , account_id
         , amount
         , authorized_date
         , imported_category
         , imported_subcategory
         , category
         , subcategory
         , check_number
         , date
         , iso_currency_code
         , merchant_name
         , imported_name
         , name
         , payment_channel
         , is_pending
         , transaction_code
         , type
    )
    select transaction->>'transaction_id' "id" 
         , user_id
         , transaction->>'account_id' "account_id"
         , (transaction->>'amount')::numeric(28,4) * -1 "amount" --for some reason, positive values like payroll come in as negative numbers and expenses come in as positive
         , (transaction->>'authorized_date')::date "authorized_date"
         , coalesce(transaction->'category'->>0, 'Unassigned') as imported_category
         , coalesce(transaction->'category'->>1, 'Unassigned') as imported_subcategory	         
         , coalesce(transaction->'category'->>0, 'Unassigned') as category
         , coalesce(transaction->'category'->>1, 'Unassigned') as subcategory
         , transaction->>'check_number' "check_number"	 
         , (transaction->>'date')::date "date"
         , transaction->>'iso_currency_code' "iso_currency_code"	 
         , transaction->>'merchant_name' "merchant_name"		 
         , transaction->>'name' "imported_name"          
         , transaction->>'name' "name" 	 
         , transaction->>'payment_channel' "payment_channel"	 
         , (transaction->>'pending')::bool "is_pending"
         , transaction->>'transaction_code' "transaction_code"
         , transaction->>'transaction_type' "type"	 
    from(
        select user_id, institution_id, jsonb_array_elements(jsondoc->'transactions') "transaction"
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as transactions
  on conflict (id)
      do update set
      account_id = excluded.account_id,
      amount = excluded.amount,
      authorized_date = excluded.authorized_date,
      category = excluded.category,
      subcategory = excluded.subcategory,
      check_number = excluded.check_number,
      date = excluded.date,
      iso_currency_code = excluded.iso_currency_code,
      merchant_name = excluded.merchant_name,
      imported_name = excluded.name,
      payment_channel = excluded.payment_channel,
      is_pending = excluded.is_pending,
      transaction_code = excluded.transaction_code,
      type = excluded.type;

	
  END;
$BODY$;


create or replace function import_plaid_transactions(plaid_webhook_history_id integer) 
  returns void
  language plpgsql
 as $$

  begin
  
    perform plaid_insert_or_update_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_transactions(plaid_webhook_history_id);
    perform plaid_insert_or_update_categories(plaid_webhook_history_id);
    perform plaid_insert_or_update_user_categories(plaid_webhook_history_id);    
   
  end
$$;



/************************************************************************************************************
PLAID webook holdings processing
************************************************************************************************************/

-- create or replace function import_plaid_holdings(plaid_webhook_history_id integer) 
--   returns void
--   language plpgsql
--  as $$

--   begin
  
--     perform plaid_insert_or_update_accounts(plaid_webhook_history_id);
--     perform plaid_insert_or_update_holdingss(plaid_webhook_history_id);
--     -- perform plaid_insert_or_update_categories(plaid_webhook_history_id);
--     -- perform plaid_insert_or_update_user_categories(plaid_webhook_history_id);  
   
--   end
-- $$;




CREATE TABLE IF NOT EXISTS credit_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    apr_percentage numeric(28,10),
    apr_type citext,
    balance_subject_to_apr numeric(28,10),
    interest_charge_amount numeric(28,10),
    is_overdue boolean default false,
    last_payment_amount numeric(28,10),
    last_payment_date date,
    last_statement_issue_date date,
    last_statement_balance numeric(28,10),
    minimum_payment_amount numeric(28,10),
    next_payment_due_date date,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--todo need trigger to audit/log changes

CREATE TABLE IF NOT EXISTS mortgage_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    account_number citext,
    current_late_fee numeric(28,10),
    escrow_balance numeric(28,10),
    has_pmi boolean default false,
    has_prepayment_penalty boolean default false,
    interest_rate_percentage double precision,
    interest_rate_type citext,
    last_payment_amount numeric(28,10),
    last_payment_date date,
    loan_type_description citext,
    loan_term citext,
    maturity_date date,
    next_monthly_payment numeric(28,10),
    next_payment_due_date date,
    origination_date date,
    origination_principal_amount numeric(28,10),
    past_due_amount numeric(28,10),
    street citext,
    city citext,
    region citext,
    postal_code citext,
    country citext,
    ytd_interest_paid numeric(28,10),
    ytd_principal_paid numeric(28,10),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

--todo need trigger to audit/log changes


create or replace view mortgages as
select user_id
     , i.name as institution_name
     , i.url as institution_url
     , i.primary_color as institution_color
     , i.logo as institution_logo
     , a.name as account_name
     , a.mask as account_mask
     , a.current_balance as account_balance
     , a.iso_currency_code
     , a.created_at as account_created_at
     , a.updated_at as account_updated_at
     , ma.account_number
     , ma.current_late_fee
     , ma.escrow_balance
     , ma.has_pmi
     , ma.has_prepayment_penalty
     , ma.interest_rate_percentage
     , ma.interest_rate_type
     , ma.last_payment_amount
     , ma.last_payment_date
     , ma.loan_type_description
     , ma.loan_term
     , ma.maturity_date
     , ma.next_monthly_payment
     , ma.next_payment_due_date
     , ma.origination_date
     , ma.origination_principal_amount
     , ma.past_due_amount
     , ma.street
     , ma.city
     , ma.region
     , ma.postal_code
     , ma.country
     , ma.ytd_interest_paid
     , ma.ytd_principal_paid
  from accounts a
       inner join institutions i on i.id = a.institution_id
       inner join mortgage_accounts ma on ma.id = a.id
 where type='loan'
   and subtype = 'mortgage';


CREATE TABLE IF NOT EXISTS student_loan_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    account_number citext,
    --disbursement_dates date,
    expected_payoff_date date,
    interest_rate_percentage double precision,
    guarantor citext,
    is_overdue boolean default false,
    last_payment_amount numeric(28,10),
    last_payment_date date,
    last_statement_issue_date date,
    loan_name citext,
    loan_status_end_date date,
    loan_status_type citext,
    minimum_payment_amount numeric(28,10),
    next_payment_due_date date,
    origination_date date,
    origination_principal_amount numeric(28,10),
    outstanding_interest_amount numeric(28,10),
    payment_reference_number citext,
    pslf_estimated_eligibility_date date,
    pslf_payments_made integer,
    pslf_payments_remaining integer,
    repayment_plan_type citext,
    repayment_plan_description citext,
    sequence_number citext,
    servicer_street citext,
    servicer_city citext,
    servicer_region citext,
    servicer_postal_code citext,
    servicer_country citext,
    ytd_interest_paid numeric(28,10),
    ytd_principal_paid numeric(28,10),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--todo need trigger to audit/log changes


/************************************************************************************************************
PLAID webook liabilities processing
************************************************************************************************************/

CREATE OR REPLACE FUNCTION plaid_insert_or_update_credit_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin
    insert into credit_accounts(
          id
        , apr_percentage
        , apr_type
        , balance_subject_to_apr
        , interest_charge_amount
        , is_overdue
        , last_payment_amount
        , last_payment_date
        , last_statement_issue_date
        , last_statement_balance
        , minimum_payment_amount
        , next_payment_due_date
    )
    select credit->>'account_id' "id"
          , (credit->'aprs'->>'apr_percentage')::numeric(28,4) "apr_percentage"
          , (credit->'aprs'->>'apr_type') "apr_type"
          , (credit->'aprs'->>'balance_subject_to_apr')::numeric(28,4) "balance_subject_to_apr"
          , (credit->'aprs'->>'interest_charge_amount')::numeric(28,4) "interest_charge_amount"
          , coalesce(credit->>'is_overdue', 'false')::boolean "is_overdue"
          , (credit->>'last_payment_amount')::numeric(28,4) "last_payment_amount"
          , (credit->>'last_payment_date')::date "last_payment_date"
          , (credit->>'last_statement_issue_date')::date "last_statement_issue_date"         
          , (credit->>'last_statement_balance')::numeric(28,4)  "last_statement_balance"   
          , (credit->>'minimum_payment_amount')::numeric(28,4) "minimum_payment_amount"   
          , (credit->>'next_payment_due_date')::date "next_payment_due_date"              
    from(
        select user_id
             , institution_id
             , jsonb_array_elements(
                case jsonb_typeof(jsondoc->'liabilities'->'credit') 
                    when 'array' then jsondoc->'liabilities'->'credit' 
                    else '[]' end
                ) as credit     
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as credit_accounts
    ON CONFLICT (ID)
    DO UPDATE SET
    apr_percentage = excluded.apr_percentage,
    apr_type = excluded.apr_type,
    balance_subject_to_apr = excluded.balance_subject_to_apr,
    interest_charge_amount = excluded.interest_charge_amount,
    is_overdue = excluded.is_overdue,
    last_payment_amount = excluded.last_payment_amount,
    last_payment_date = excluded.last_payment_date,
    last_statement_issue_date = excluded.last_statement_issue_date,
    last_statement_balance = excluded.last_statement_balance,
    minimum_payment_amount = excluded.minimum_payment_amount,
    next_payment_due_date = excluded.next_payment_due_date
    ;

  end;
$BODY$;

CREATE OR REPLACE FUNCTION plaid_insert_or_update_student_loan_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin
    insert into student_loan_accounts(
          id
        , account_number
        , expected_payoff_date
        , interest_rate_percentage
        , guarantor
        , is_overdue
        , last_payment_amount
        , last_payment_date
        , last_statement_issue_date
        , loan_name
        , loan_status_end_date
        , loan_status_type
        , minimum_payment_amount
        , next_payment_due_date
        , origination_date
        , origination_principal_amount
        , outstanding_interest_amount
        , payment_reference_number
        , pslf_estimated_eligibility_date
        , pslf_payments_made
        , pslf_payments_remaining
        , repayment_plan_type
        , repayment_plan_description
        , sequence_number
        , servicer_street
        , servicer_city
        , servicer_region
        , servicer_postal_code
        , servicer_country
        , ytd_interest_paid
        , ytd_principal_paid
    )
    select
              student_loan->>'account_id' 
            , student_loan->>'account_number' 
            , (student_loan->>'expected_payoff_date')::date 
            , (student_loan->>'interest_rate_percentage')::double precision 
            , student_loan->>'guarantor' 
            , coalesce(student_loan->>'is_overdue', 'false')::boolean 
            , (student_loan->>'last_payment_amount')::numeric(28,4) 
            , (student_loan->>'last_payment_date')::date 
            , (student_loan->>'last_statement_issue_date')::date 
            , student_loan->>'loan_name' "loan_name"
            , (student_loan->'loan_status'->>'end_date')::date       
            , (student_loan->'loan_status'->>'ltype')::date      
            , (student_loan->>'minimum_payment_amount')::numeric(28,4)
            , (student_loan->>'next_payment_due_date')::date
            , (student_loan->>'origination_date')::date
            , (student_loan->>'origination_principal_amount')::numeric(28,4)
            , (student_loan->>'outstanding_interest_amount')::numeric(28,4)
            , student_loan->>'payment_reference_number'
            , (student_loan->'pslf_status'->>'estimated_eligibility_date')::date               
            , (student_loan->'pslf_status'->>'payments_made')::integer   
            , (student_loan->'pslf_status'->>'payments_remaining')::integer   
            , student_loan->'repayment_plan'->>'type'
            , student_loan->'repayment_plan'->>'description'   
            , student_loan->>'sequence_number'
            , student_loan->'servicer_address'->>'street'
            , student_loan->'servicer_address'->>'city'
            , student_loan->'servicer_address'->>'region'
            , student_loan->'servicer_address'->>'postal_code'            
            , student_loan->'servicer_address'->>'country'  
            , (student_loan->>'ytd_interest_paid')::numeric(28,4)
            , (student_loan->>'ytd_principal_paid')::numeric(28,4)
    from(
        select user_id
             , institution_id
             , jsonb_array_elements(
                case jsonb_typeof(jsondoc->'liabilities'->'student') 
                     when 'array' then jsondoc->'liabilities'->'student' 
                     else '[]' 
                end
                ) as student_loan
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as student_loan_accounts
    ON CONFLICT (ID)
    DO UPDATE SET
      account_number = excluded.account_number
    , expected_payoff_date = excluded.expected_payoff_date
    , interest_rate_percentage = excluded.interest_rate_percentage
    , guarantor = excluded.guarantor
    , is_overdue = excluded.is_overdue
    , last_payment_amount = excluded.last_payment_amount
    , last_payment_date = excluded.last_payment_date
    , last_statement_issue_date = excluded.last_statement_issue_date
    , loan_name = excluded.loan_name
    , loan_status_end_date = excluded.loan_status_end_date
    , loan_status_type = excluded.loan_status_type
    , minimum_payment_amount = excluded.minimum_payment_amount
    , next_payment_due_date = excluded.next_payment_due_date
    , origination_date = excluded.origination_date
    , origination_principal_amount = excluded.origination_principal_amount
    , outstanding_interest_amount = excluded.outstanding_interest_amount
    , payment_reference_number = excluded.payment_reference_number
    , pslf_estimated_eligibility_date = excluded.pslf_estimated_eligibility_date
    , pslf_payments_made = excluded.pslf_payments_made
    , pslf_payments_remaining = excluded.pslf_payments_remaining
    , repayment_plan_type = excluded.repayment_plan_type
    , repayment_plan_description = excluded.repayment_plan_description
    , sequence_number = excluded.sequence_number
    , servicer_street = excluded.servicer_street
    , servicer_city = excluded.servicer_city
    , servicer_region = excluded.servicer_region
    , servicer_postal_code = excluded.servicer_postal_code
    , servicer_country = excluded.servicer_country
    , ytd_interest_paid = excluded.ytd_interest_paid
    , ytd_principal_paid = excluded.ytd_principal_paid;

  end;
$BODY$;

CREATE OR REPLACE FUNCTION plaid_insert_or_update_mortgage_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin
    insert into mortgage_accounts(
          id
        , account_number
        , current_late_fee
        , escrow_balance
        , has_pmi
        , has_prepayment_penalty
        , interest_rate_percentage
        , interest_rate_type
        , last_payment_amount
        , last_payment_date
        , loan_type_description
        , loan_term
        , maturity_date
        , next_monthly_payment
        , next_payment_due_date
        , origination_date
        , origination_principal_amount
        , past_due_amount
        , street
        , city
        , region
        , postal_code
        , country
        , ytd_interest_paid
        , ytd_principal_paid
    )
    select
              (mortgage->>'account_id')::text
            , (mortgage->>'account_number')::citext
            , (mortgage->>'current_late_fee')::numeric(28,8)
            , (mortgage->>'escrow_balance')::numeric(28,8)
            , coalesce(mortgage->>'has_pmi', 'false')::boolean
            , coalesce(mortgage->>'has_prepayment_penalty', 'false')::boolean   
            , (mortgage->'interest_rate'->>'percentage')::double precision
            , (mortgage->'interest_rate'->>'type')::citext
            , (mortgage->>'last_payment_amount')::numeric(28,8)
            , (mortgage->>'last_payment_date')::date
            , (mortgage->>'loan_type_description')::citext
            , (mortgage->>'loan_term')::citext
            , (mortgage->>'maturity_date')::date
            , (mortgage->>'next_monthly_payment')::numeric(28,8)
            , (mortgage->>'next_payment_due_date')::date
            , (mortgage->>'origination_date')::date
            , (mortgage->>'origination_principal_amount')::numeric(28,8)
            , (mortgage->>'past_due_amount')::numeric(28,8)
            , (mortgage->'property_address'->>'street')::citext
            , (mortgage->'property_address'->>'city')::citext
            , (mortgage->'property_address'->>'region')::citext
            , (mortgage->'property_address'->>'postal_code')::citext
            , (mortgage->'property_address'->>'country')::citext
            , (mortgage->>'ytd_interest_paid')::numeric(28,8)
            , (mortgage->>'ytd_principal_paid')::numeric(28,8)
    from(
        select user_id
             , institution_id
             , jsonb_array_elements(
                case jsonb_typeof(jsondoc->'liabilities'->'mortgage') 
                     when 'array' then jsondoc->'liabilities'->'mortgage' 
                     else '[]' 
                end
                ) as mortgage
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as mortgage_loan_accounts
    ON CONFLICT (ID)
    DO UPDATE SET
      account_number = excluded.account_number
    , current_late_fee = excluded.current_late_fee
    , escrow_balance = excluded.escrow_balance
    , has_pmi = excluded.has_pmi
    , has_prepayment_penalty = excluded.has_prepayment_penalty
    , interest_rate_percentage = excluded.interest_rate_percentage
    , interest_rate_type = excluded.interest_rate_type
    , last_payment_amount = excluded.last_payment_amount
    , last_payment_date = excluded.last_payment_date
    , loan_type_description = excluded.loan_type_description
    , loan_term = excluded.loan_term
    , maturity_date = excluded.maturity_date
    , next_monthly_payment = excluded.next_monthly_payment
    , next_payment_due_date = excluded.next_payment_due_date
    , origination_date = excluded.origination_date
    , origination_principal_amount = excluded.origination_principal_amount
    , past_due_amount = excluded.past_due_amount
    , street = excluded.street
    , city = excluded.city
    , region = excluded.region
    , postal_code = excluded.postal_code
    , country = excluded.country
    , ytd_interest_paid = excluded.ytd_interest_paid
    , ytd_principal_paid = excluded.ytd_principal_paid;

  end;
$BODY$;


create or replace function import_plaid_liabilities(plaid_webhook_history_id integer) 
  returns void
  language plpgsql
 as $$

  begin
    perform plaid_insert_or_update_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_credit_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_student_loan_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_mortgage_accounts(plaid_webhook_history_id);

  end
$$;


create or replace function import_plaid_webhook_history_data() 
  returns trigger
  language plpgsql
 as $$
  declare
    schemaName text;
    tableName text;
    columnName text;    
    sqlErrorCode text;
    constraintName text;
    dataType text;
    exceptionMessage text;
    exceptionDetail text;
    exceptionHint text;
    exceptionContext text;
    jsonError jsonb;
    webhooktype text;
  begin
    select webhook_type from plaid_webhook_history where id = NEW.plaid_webhook_history_id into webhooktype;
    -- raise notice 'webhook_type: %', webhooktype;

    if webhooktype = 'LIABILITIES' then
       perform import_plaid_liabilities(NEW.plaid_webhook_history_id);
    elsif webhooktype = 'TRANSACTIONS' then
       perform import_plaid_transactions(NEW.plaid_webhook_history_id);
    -- elsif webhooktype = 'HOLDINGS' then
    --    perform import_plaid_holdings(NEW.plaid_webhook_history_id);
    -- elsif webhooktype = 'INVESTMENTS_TRANSACTIONS' then
    --    perform import_plaid_investment_holdings(NEW.plaid_webhook_history_id);             
    end if;


    
    update plaid_webhook_history_data 
       set imported_at=now()
     where id=NEW.id;

    return null;

  exception when others then
      get stacked diagnostics
          schemaName=SCHEMA_NAME, -- the name of the schema related to exception
          tableName=TABLE_NAME,   -- the name of the table related to exception
          columnName=COLUMN_NAME, -- the name of the column related to exception          
          sqlErrorCode=RETURNED_SQLSTATE, -- the SQLSTATE error code of the exception
          constraintName=CONSTRAINT_NAME, -- the name of the constraint related to exception
          dataType=PG_DATATYPE_NAME,      -- the name of the data type related to exception
          exceptionMessage=MESSAGE_TEXT,  -- the text of the exception's primary message
          exceptionDetail=PG_EXCEPTION_DETAIL,   -- the text of the exception's detail message, if any
          exceptionHint=PG_EXCEPTION_HINT,       -- the text of the exception's hint message, if any
          exceptionContext=PG_EXCEPTION_CONTEXT -- line(s) of text describing the call stack at the time of the exception
      ;
      
    jsonError=jsonb_build_object(
            'schemaName', schemaName,
            'tableName', tableName,
            'columnName', columnName,
            'sqlErrorCode', sqlErrorCode,
            'constraintName', constraintName,
            'dataType', dataType,
            'exceptionMessage', exceptionMessage,
            'exceptionDetail', exceptionDetail,
            'exceptionHint', exceptionHint,
            'exceptionContext', exceptionContext
         );
         
    -- raise notice 'error: %', jsonError;         

    update plaid_webhook_history_data
       set importError = jsonError
     where id=NEW.id;

    return null;
   
  end
$$;


create or replace trigger plaid_webhook_history_data_trigger
 after insert on plaid_webhook_history_data
   for each row execute procedure import_plaid_webhook_history_data();




-- CREATE FUNCTION category_insert_values() RETURNS trigger AS $$
--   BEGIN
--     NEW.subcategory :=COALESCE(NEW.subcategory, 'General');
--     RETURN NEW;
--   END
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER category_trigger
-- BEFORE INSERT OR UPDATE ON categories
-- FOR EACH ROW EXECUTE PROCEDURE category_insert_values();


create or replace function save_and_run_rule(userId integer, rule jsonb, ruleId integer default null)
  returns void as $$
  declare
    new_rule_id integer;
  BEGIN


    if ruleId is NULL then
        insert into user_rules(user_id, rule) 
             values (userId,rule) 
                 on conflict do nothing
          returning id into new_rule_id ;

    else
        update user_rules
           set rule = $2
         where user_id = userId
           and id = ruleId;
    end if;    


    -- RAISE NOTICE 'new_rule_id: %', new_rule_id;
    
    -- execute (
    --   select format( 'update %I set %s where user_id=%s and %s;'
    --                , 'tansactions' -- ur.rule->>'tablename'
    --                , set_columns.cols
    --                , user_id
    --                , where_columns.cols
    --                )
    --     from user_rules ur
    --     cross join lateral (
    --           select string_agg(quote_ident(col->>'name') || '=' || '' ||  quote_literal(col->>'value'), ', ') AS cols
    --             from jsonb_array_elements(ur.rule->'set') col
    --           ) set_columns
    --     cross join lateral (
    --           select string_agg(quote_ident(col->>'name') || ' ' 
    --                             || case (col->>'condition')::citext when 'equals' then '=' else 'like 'end 
    --                             || '' 
    --                             || 
    --                            case (col->>'condition')::citext
    --                            when 'equals' then quote_literal(col->>'value')
    --                            when 'starts with' then quote_literal(col->>'value'||'%')
    --                            when 'ends with' then quote_literal( format('%s%s', '%',col->>'value' )  )
    --                            else 'like'
    --                             end
    --                            , ' and ') AS cols
    --             from jsonb_array_elements(ur.rule->'where') col
    --           ) where_columns
    --     where user_id=userId
    --       and id=new_rule_id
    --   );
  END;
$$ language plpgsql;
















CREATE OR REPLACE FUNCTION user_spending_metrics_by_category_subcategory(userId integer, startDate date, endDate date, exclude_non_budgeted_categories bool default false)
RETURNS TABLE (
   user_category_id	 integer
 , user_category citext
 , user_subcategory citext
 , min_budgeted_amount numeric(28,2)	
 , max_budgeted_amount numeric(28,2)
 , min_monthly_spend numeric(28,2)	
 , avg_monthly_spend numeric(28,2)	
 , max_monthly_spend numeric(28,2)	
 , total_spend numeric(28,2)
 , do_not_budget bool
)
AS $$
DECLARE 

BEGIN
RETURN QUERY
  select user_ledger.user_category_id
      , user_ledger.user_category
      , user_ledger.user_subcategory
      , user_ledger.min_budgeted_amount
      , user_ledger.max_budgeted_amount        
      , max(user_ledger.monthly_total)::numeric(28,2) as min_monthly_spend
      , avg(user_ledger.monthly_total)::numeric(28,2) as avg_monthly_spend   
      , min(user_ledger.monthly_total)::numeric(28,2) as max_monthly_spend
      , sum(user_ledger.monthly_total)::numeric(28,2) as total_amount_spent
      , user_ledger.do_not_budget
    from (
          select timespan.user_category_id
              , timespan.end_of_month
              , timespan.user_category
              , timespan.user_subcategory
              , timespan.min_budgeted_amount
              , timespan.max_budgeted_amount      
              , coalesce(transaction_monthy_totals.monthly_total,0) as monthly_total
              , timespan.do_not_budget      
            from (
                  select uc.id as user_category_id
                      , user_categories_by_date_range.end_of_month
                      , uc.user_category
                      , uc.user_subcategory
                      , uc.min_budgeted_amount
                      , uc.max_budgeted_amount
                      , 0 as monthly_total
                      , uc.do_not_budget              
                    from user_categories uc
                  cross join (
                              select end_of_month(date_series::date) as end_of_month
                              from generate_series( startDate, endDate, '1 month'::interval) date_series
                            ) as user_categories_by_date_range
                  where uc.user_id = userId
                    and (uc.do_not_budget = false or uc.do_not_budget != exclude_non_budgeted_categories)
          ) as timespan
          left join (
                  select end_of_month(date) as end_of_month
                      , category
                      , subcategory
                      , sum(amount) monthly_total
                    from transactions
                  where user_id = userId
                    and date between startDate and endDate
                  group by end_of_month, category, subcategory
          ) as transaction_monthy_totals
            on transaction_monthy_totals.end_of_month = timespan.end_of_month
            and transaction_monthy_totals.category = timespan.user_category
            and transaction_monthy_totals.subcategory = timespan.user_subcategory
      ) as user_ledger
  group by user_ledger.user_category_id
        , user_ledger.user_category
        , user_ledger.user_subcategory
        , user_ledger.min_budgeted_amount
        , user_ledger.max_budgeted_amount        
        , user_ledger.do_not_budget
  order by user_ledger.user_category
        , user_ledger.user_subcategory;

END; $$ 
LANGUAGE 'plpgsql';





-- update transactions
--   set category = uc.user_category ,
--       subcategory = uc.user_subcategory
--  from user_categories uc
-- where transactions.user_id = 1
--   and transactions.category = uc.category
--   and transactions.subcategory = uc.subcategory




-- CREATE OR REPLACE FUNCTION get_spending_metrics_by_category_subcategory(
--   userId integer,
--   startYear integer,
--   startMonth integer,
--   endMonth integer
-- ) RETURNS TABLE (
--   category citext,
--   subcategory citext,
--   min numeric(28, 2),
--   max numeric(28, 2),
--   avg numeric(28, 2)
-- ) AS $$ 
-- BEGIN 
-- RETURN QUERY
-- select
--   ledger.category,
--   ledger.subcategory,
--   sum(ledger.min) min,
--   sum(ledger.max) max,
--   sum(ledger.avg) avg
-- from
--   (
--     select
--       t.category,
--       t.subcategory,
--       round(max(t.total), 2) min,
--       round(min(t.total), 2) max,
--       round(avg(t.total), 2) avg
--     from(
--         select
--           months.month,
--           user_categories.category,
--           user_categories.subcategory,
--           coalesce(round(sum(t.amount), 2), 0) as total
--         from
--           generate_series(startMonth, endMonth) as months(month)
--           cross join (
--             select
--               t.category,
--               t.subcategory
--             from
--               transactions t
--             where
--                  user_id = userId
--               and year = startYear
--               and month between startMonth
--               and endMonth
--               and amount < 0
--             group by
--               t.category,
--               t.subcategory
--             order by
--               t.category,
--               t.subcategory
--           ) as user_categories
--           left join transactions t on t.month = months.month
--           and t.category = user_categories.category
--           and t.subcategory = user_categories.subcategory
--           and amount < 0
--         group by
--           months.month,
--           user_categories.category,
--           user_categories.subcategory
--       ) t
--     GROUP BY
--       t.category,
--       t.subcategory
--     UNION
--     select
--       t.category,
--       t.subcategory,
--       round(min(t.total), 2) min,
--       round(max(t.total), 2) max,
--       round(avg(t.total), 2) avg
--     from(
--         select
--           months.month,
--           user_categories.category,
--           user_categories.subcategory,
--           coalesce(round(sum(t.amount), 2), 0) as total
--         from
--           generate_series(1, 12) as months(month)
--           cross join (
--             select
--               t.category,
--               t.subcategory
--             from
--               transactions t
--               inner join accounts a on a.id = t.account_id
--             where
--               a.user_id = userId
--               and t.year = startYear
--               and month between startMonth
--               and endMonth
--               and amount > 0
--             group by
--               t.category,
--               t.subcategory
--             order by
--               t.category,
--               t.subcategory
--           ) as user_categories
--           left join transactions t 
-- 	        on t.month = months.month
--            and t.category = user_categories.category
--            and t.subcategory = user_categories.subcategory
--            and amount > 0
--         group by
--           months.month,
--           user_categories.category,
--           user_categories.subcategory
--         order by
--           months.month,
--           user_categories.category,
--           user_categories.subcategory
--       ) t
--     GROUP BY
--       t.category,
--       t.subcategory
--   ) as ledger
-- GROUP BY
--   ledger.category,
--   ledger.subcategory
-- ORDER BY
--   ledger.category,
--   ledger.subcategory;
-- END;$$ 
-- LANGUAGE 'plpgsql';

-- select * from GetSpendingMetricsByCategoryAndSubcategory(1,2021,1,12)






-- starts with
select * from transactions
where imported_name ~* '^grub.*$';

-- ends with
select * from transactions
where imported_name ~* '.*pharmacy$'

-- contains
select * from transactions
where imported_name ~* '.*life.*$'

--equals
select * from transactions
where imported_name ~ '^COSERV ELECTRIC$'







WITH spending AS (
 SELECT * FROM crosstab(
     $$ select category || '>' || subcategory,
	           to_char(date, 'mon'), 
	           round(sum(amount),2) AS total
          from transactions
         inner join accounts on accounts.id = transactions.account_id
	     where user_id = 1
	       and year = 2021
	       and month between 1 and 12
         group by category,subcategory,2
         order by 1,2 
	 $$
    ,$$VALUES ('jan'), ('feb'), ('mar'), ('apr'), ('may'), ('jun'), ('jul'), ('aug'), ('sep'), ('oct'), ('nov'), ('dec')$$
   )
 AS ct (category citext, jan numeric(28,2), feb numeric(28,2), mar numeric(28,2), apr numeric(28,2), may numeric(28,2), jun numeric(28,2), jul numeric(28,2), aug numeric(28,2), sep numeric(28,2), oct numeric(28,2), nov numeric(28,2), dec numeric(28,2))	
)
SELECT 
    (regexp_split_to_array(category, '>'))[1] as category, 
    (regexp_split_to_array(category, '>'))[2] as subcategory, 
    COALESCE(jan, 0) jan,
    COALESCE(feb, 0) feb,
    COALESCE(mar, 0) mar,
    COALESCE(apr, 0) apr,
    COALESCE(may, 0) may,
    COALESCE(jun, 0) jun,
    COALESCE(jul, 0) jul,
    COALESCE(aug, 0) aug,
    COALESCE(sep, 0) sep,
    COALESCE(oct, 0) oct,
    COALESCE(nov, 0) nov,
    COALESCE(dec, 0) dec,
	round((
		COALESCE(jan, 0) +
		COALESCE(feb, 0) +
		COALESCE(mar, 0) +
		COALESCE(apr, 0) +
		COALESCE(may, 0) +
		COALESCE(jun, 0) +
		COALESCE(jul, 0) +
		COALESCE(aug, 0) +
		COALESCE(sep, 0) +
		COALESCE(oct, 0) +
		COALESCE(nov, 0) +
		COALESCE(dec, 0)		
	)/12,2) as yearly_average
FROM spending;




























CREATE OR REPLACE FUNCTION GetSpendingByCategory(userId integer, startDate date, endDate date)
RETURNS TABLE (
 category text,
 amount numeric(28,10)
)
AS $$
BEGIN
RETURN QUERY select t.category, sum(t.amount) as amount
  from transactions t
 INNER JOIN accounts a on a.id = t.account_id
 WHERE a.user_id = userId
   and date between startDate and endDate
   and t.category != 'Payment'
   and t.category != 'Transfer'
   and t.category != 'Interest'
 GROUP BY t.category;
END; $$ 
LANGUAGE 'plpgsql';





CREATE OR REPLACE FUNCTION GetSpendingBySubCategory(userId integer, category text, startDate date, endDate date)
RETURNS TABLE (
 sub_category text,
 amount numeric(28,10)
)
AS $$
BEGIN
RETURN QUERY 
SELECT subcategory, sum(t.amount) as amount
  FROM transactions t
 INNER JOIN accounts a on a.id = t.account_id  
 WHERE a.user_id = userId
   and t.category = $2
   and t.date between startDate and endDate
   and t.category != 'Payment'
   and t.category != 'Transfer'
   and t.category != 'Interest'   
 group by sub_category;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION GetSpendingByDates(userId integer, startDate date, endDate date)
RETURNS TABLE (
 date text,
 amount numeric(28,10)
)
AS $$
BEGIN
RETURN QUERY 
	SELECT to_char(summed_transactions.date, 'Mon YYYY') date , sum(summed_transactions.amount) amount 
	FROM (
		SELECT t.date, to_date(to_char(t.date, 'Mon YYYY'), 'Mon YYYY') formatted_date, sum(t.amount) amount
		  FROM transactions t
	 INNER JOIN accounts a on a.id = t.account_id
		  WHERE a.user_id = userId
		   and t.category != 'Payment'
		   and t.category != 'Transfer'
		   and t.category != 'Interest'
		 group by t.date
		 order by t.date desc
	) as summed_transactions
	group by 1, summed_transactions.formatted_date
	order by summed_transactions.formatted_date desc;
END; $$ 
LANGUAGE 'plpgsql';

--http://johnatten.com/2015/04/22/use-postgres-json-type-and-aggregate-functions-to-map-relational-data-to-json/
/*
    SELECT
    (SELECT COUNT(t.*) FROM transactions t INNER JOIN accounts a on a.id = t.account_id WHERE a.user_id = userId AND date BETWEEN startDate AND endDate) as count, 
    (SELECT json_agg(t.*) 
       FROM (
           SELECT t.id, a.name as account, t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
		     FROM transactions t
	        INNER JOIN accounts a on a.id = t.account_id		   
		   	WHERE a.user_id = userId
              AND date BETWEEN startDate AND endDate		   
            ORDER BY date desc
           OFFSET page - 1 --use 1 based indexing to match UI
            LIMIT pageSize
     ) AS t
    ) AS data;
*/


-- CREATE OR REPLACE FUNCTION get_transactions_by_date_range(userId integer, startDate date, endDate date, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	  INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
--         AND date BETWEEN startDate AND endDate
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            SELECT t.id, a.name as account, t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
--               AND date BETWEEN startDate AND endDate		   
--             ORDER BY date desc
--            OFFSET page - 1 --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION get_transactions(userId integer, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	    INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            SELECT t.id, a.name as account, t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
--             ORDER BY date desc
--            OFFSET page - 1 --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION get_account_transactions(userId integer, accountId text, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	  INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
-- 	    AND a.id = accountId
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            SELECT t.id, a.name as account,t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
-- 	          AND a.id = accountId		   
--             ORDER BY date desc
--            OFFSET page - 1 --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION get_account_transactions_by_daterange(userId integer, accountId text, startDate date, endDate date, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	  INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
-- 	    AND a.id = accountId	 
--         AND date BETWEEN startDate AND endDate
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            select t.id, t.date, a.name account, t.name, t.category as category, t.subcategory as subcategory, t.amount, t.iso_currency_code
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
-- 		   	  AND a.id = accountId
--               AND date BETWEEN startDate AND endDate		   
--             ORDER BY date desc
--            OFFSET page  --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';







-- CREATE OR REPLACE FUNCTION get_transactions(userId integer, accountId text default null, startDate date default null, endDate date default null, page integer default 1, pageSize integer default 1, sortBy text default 'date', sortDirection text default'asc')
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- DECLARE 
--  selectStmt VARCHAR;
--  whereStmt VARCHAR := ' WHERE a.user_id = '|| quote_literal(userId); 
--  sortByColumn VARCHAR := sortBy;
--  sortColumnDirection VARCHAR := sortDirection; 
-- BEGIN
--     IF sortByColumn IS NULL THEN
--      sortByColumn := 'date';
--     END IF;
	

--      IF sortColumnDirection IS NULL THEN
--  		IF sortByColumn = 'date' THEN
--  		   sortColumnDirection := 'desc';
-- 		ELSE
--  		   sortColumnDirection := 'asc';
--  		END IF;
--      END IF;
	
-- -- 	raise notice 'sortByColumn: %', sortByColumn;
-- -- 	raise notice 'sortColumnDirection: %', sortColumnDirection;
	
--     IF accountId IS NOT NULL THEN
--         whereStmt := whereStmt || ' AND a.id = '|| quote_literal(accountId) ||' ';
--     END IF;
   
--     IF startDate IS NOT NULL AND endDate IS NOT NULL THEN
-- 	    whereStmt := whereStmt || ' AND date BETWEEN '|| quote_literal(startDate) ||' AND '|| quote_literal(endDate) ||' ';
--     END IF;   
   
--    selectStmt := 'SELECT (SELECT COUNT(t.*) FROM transactions t INNER JOIN accounts a on a.id = t.account_id '
--    || whereStmt ||
--    ') as count, ' 
--    '(SELECT json_agg(t.*) '
-- 	  'FROM ( '
-- 	  ' select t.id, t.date, a.name account, t.name, t.category as category, t.subcategory as subcategory, t.amount, t.iso_currency_code FROM transactions t '
-- 	  ' INNER JOIN accounts a on a.id = t.account_id '
-- 	  || whereStmt ||
--       ' ORDER BY '|| sortByColumn ||' ' || sortColumnDirection ||
--       '  OFFSET '|| quote_literal(page) ||' '
--       '  LIMIT '|| quote_literal(pageSize) ||' '
-- 	  ') AS t'
-- 	 ' ) as data';
   
-- -- raise notice 'SQL: %', selectStmt;   
   
-- RETURN QUERY EXECUTE selectStmt;

-- END; $$ 
-- LANGUAGE 'plpgsql';


create or replace view user_transactions as
select a.user_id
      ,t.id
      ,a.name as account
	    ,a.id as account_id
	    ,t.date
      ,t.name
      ,t.category as category
      ,t.subcategory as subcategory
      ,t.amount
      ,t.iso_currency_code
	    ,t.is_pending
  from transactions t
 inner join accounts a on a.id = t.account_id;

create or replace view user_accounts as
select 
    a.id
  , a.user_id
  , i.name as institution
  , i.url as institution_url
  , i.primary_color as institution_color
  , i.logo as institution_logo   
  , a.name
  , a.mask
  , a.official_name
  , a.current_balance
  , a.available_balance
  , a.account_limit
  , a.iso_currency_code
  , a.type
  , a.subtype
  , a.last_import_date
from accounts a 
     inner join institutions i on a.institution_id = i.id;








SELECT
  (SELECT COUNT(*)
     FROM transactions
    WHERE  account_id = 'mzd5mpxAonCE3NpPmvLEFGdj1dEogWhLkpzbA'
  ) as count, 
  (SELECT json_agg(t.*) 
     FROM (
	       SELECT * FROM transactions
	        WHERE  account_id = 'mzd5mpxAonCE3NpPmvLEFGdj1dEogWhLkpzbA'
	        ORDER BY date
	       OFFSET 0
	        LIMIT 5
	 ) AS t
  ) AS rows


 select date_trunc('month', t.date) as month, category, sum(amount) amount
  from transactions t 
  group by 1, 2
  order by 1 desc, 2;

select distinct category, 
       avg(sum(amount)) over (partition by category)  amount
  from (
	    select category, 
	           amount,
	           date
    from transactions
 INNER JOIN accounts a on a.id = account_id
 WHERE a.user_id = 1
   and date between '2021/11/01' and '2021/11/30' 	  
  ) x
 group by date_trunc('month', date), category
 
 select distinct t.category, avg(sum(t.amount)) over (partition by t.category)  amount
  from transactions t
 INNER JOIN accounts a on a.id = t.account_id
 WHERE a.user_id = 1
   and date between '2021/11/01' and '2021/11/30' 
 group by date_trunc('month', t.date), category
 order by 1;



  
select distinct category, 
       avg(sum(amount)) over (partition by category)  amount
  from (
	    select category,
	      amount,
	  date
    from transactions
 INNER JOIN accounts a on a.id = account_id
 WHERE a.user_id = 1
   and date between '2021/11/01' and '2021/11/30' 	  
  ) x
 group by date_trunc('month', date), category;  



 -- Category spend trends year over year
select year, 
       month, 
       category, 
	   average_amount,
	   lag(average_amount, 1) OVER (PARTITION BY month, category ORDER BY year, month ) as previous_year,
	   lag(average_amount, 1) OVER (PARTITION BY month, category ORDER BY year, month ) - average_amount as difference,
       (100 * (average_amount - lag(average_amount, 1) over (PARTITION BY month, category ORDER BY year, month)) / lag(average_amount, 1) over (PARTITION BY month, category ORDER BY year, month)) as percent_diff
from (
	select distinct year, month, 
		   category,
		   avg(amount) OVER (PARTITION BY month, category ORDER BY year, month) average_amount
	from transactions
	order by category, month
) t

-- Category spend trends by month
select month, 
       category, 
	   average_amount,
	   lag(average_amount, 1) OVER (PARTITION BY month, category ORDER BY month ) as previous_month
from (
	select distinct month, 
		   category,
		   avg(amount) OVER (PARTITION BY month, category ORDER BY month ) as average_amount
	from transactions
	where year = 2021
	order by category, month
) t



-- Categories JSON Hierarchy
-- select json_agg(json_user_categories)
-- from (
--   select cats.user_category as label, cats.user_category as value, json_agg(json_build_object('label', subCats.user_subcategory,'value', subCats.user_subcategory)) as subcategories
--   from (
-- 	  select distinct cats.user_category from user_categories cats where user_id = 1
--   ) cats
--   join (
-- 	  select distinct user_category, user_subcategory from user_categories where user_id = 1
--   ) subCats on cats.user_category = subCats.user_category
--  group by cats.user_category
-- 	order by cats.user_category
-- ) json_user_categories









-- select *
--      , category as imported_category
--      , subcategory as imported_subcategory
--      , name as imported_name	 
-- from(
-- 	select transaction->>'transaction_id' "transaction_id" 
-- 		 , transaction->>'account_id' "account_id"
-- 		 , (transaction->>'amount')::numeric(28,4) "amount"
-- 		 , transaction->>'authorized_date' "authorized_date"
-- 		 , transaction->'category'->>0 as category
-- 		 , transaction->'category'->>1 as subcategory	
-- 		 , transaction->>'check_number' "check_number"	 
-- 		 , (transaction->>'date')::date "date"
-- 		 , transaction->>'iso_currency_code' "iso_currency_code"	 
-- 		 , transaction->>'merchant_name' "merchant_name"		 
-- 		 , transaction->>'name' "name" 	 
-- 		 , transaction->>'payment_channel' "payment_channel"	 
-- 		 , transaction->>'pending' "is_pending"
-- 		 , transaction->>'transaction_code' "transaction_code"
-- 		 , transaction->>'transaction_type' "transaction_type"	 
-- 	from transaction_import_history,
--          lateral jsonb_array_elements(transaction_import_history.data) transaction
-- ) as transaction_date






      -- WITH type_subtype_grouped_accounts as (
      --   select type
      --       , subtype
      --       , json_agg( 
      --         json_build_object(
      --           'id', id
      --         , 'institution', institution
      --         , 'name', name
      --         , 'mask', mask
      --         , 'official_name', official_name
      --         , 'current_balance', current_balance
      --         , 'available_balance', available_balance
      --         , 'account_limit', account_limit
      --         , 'iso_currency_code', iso_currency_code
      --         )) AS accounts
      --   from user_accounts ua
      -- where user_id = ${userId}     
      -- GROUP BY type, subtype
      -- )
      -- select type, json_object_agg(subtype, accounts) as accounts
      --   from (select type, subtype,  accounts from type_subtype_grouped_accounts) x
      --   group by type   