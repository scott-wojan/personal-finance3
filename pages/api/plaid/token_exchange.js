import { getAccessToken } from "integrations/plaid/tokens";
import { getInstitutionById } from "integrations/plaid/institutions";
import { getUserFromCookie, setUserCookie } from "cookies/user";
import { getUserAccountsForBank } from "integrations/plaid/accounts";
import { saveUserAccounts } from "database/accounts";
import {
  associateInstitutionToUser,
  saveInstitution,
} from "database/institutions";

export default async function handler(req, res) {
  const { public_token, metadata } = req.body;
  const user = getUserFromCookie(req, res);
  try {
    const { access_token: accessToken, item_id: itemId } = await getAccessToken(
      public_token
    );

    // insert institution
    const institution = await getInstitutionById(
      metadata.institution.institution_id
    );

    await saveInstitution(institution);

    // associate institution to user
    await associateInstitutionToUser({
      itemId,
      institutionId: institution.institution_id,
      userId: user.id,
      accessToken,
    });

    const accounts = await getUserAccountsForBank(accessToken);

    await saveUserAccounts({
      userId: user.id,
      institutionId: institution.institution_id,
      accessToken,
      accounts,
    });

    setUserCookie(req, res, { ...user, has_accounts: true });

    return res.status(200).json({});
  } catch (error) {
    return res.status(400).json(error);
  }
}
