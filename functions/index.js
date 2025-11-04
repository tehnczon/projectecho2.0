const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {KeyManagementServiceClient} = require("@google-cloud/kms");
const crypto = require("crypto");

admin.initializeApp();
const kmsClient = new KeyManagementServiceClient();

// TODO: update these with your actual KMS key info
const projectId = "forward-ellipse-463813-a5";
const locationId = "asia-southeast1";
const keyRingId = "user-data-ring";
const keyId = "phone-encryption-key";

exports.encryptPhone = functions.https.onRequest(async (req, res) => {
  try {
    const {phoneNumber} = req.body;
    if (!phoneNumber) {
      return res.status(400).json({error: "Missing phone number"});
    }

    // 🔒 Use Cloud KMS to encrypt the phone number
    // eslint-disable-next-line max-len
    const name = kmsClient.cryptoKeyPath(projectId, locationId, keyRingId, keyId);
    const [result] = await kmsClient.encrypt({
      name,
      plaintext: Buffer.from(phoneNumber),
    });

    const encrypted = result.ciphertext.toString("base64");

    // Optional: create deterministic HMAC for lookups
    const hmacKey = "replace-with-your-strong-secret-key";
    const phoneHmac = crypto
        .createHmac("sha256", hmacKey)
        .update(phoneNumber)
        .digest("hex");

    // Store encrypted value and HMAC (never store plaintext!)
    await admin.firestore().collection("users").add({
      phone_encrypted: encrypted,
      phone_hmac: phoneHmac,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({
      success: true,
      encrypted,
      phoneHmac,
    });
  } catch (error) {
    console.error("Encryption error:", error);
    res.status(500).json({error: error.message});
  }
});
