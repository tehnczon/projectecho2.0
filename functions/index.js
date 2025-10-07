/* eslint-disable max-len */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const {FieldValue} = admin.firestore;

// ---------- Helpers ----------
const getFieldValue = (field, fallback = "Unknown") => {
  if (field === null || field === undefined) return fallback;
  if (typeof field === "boolean") return field.toString();
  return field.toString();
};

// ---------- Cloud Function ----------
exports.updateAnalyticsCounts = onDocumentCreated("analyticsData/{userId}", async (event) => {
  const data = event.data.data();
  const analyticsRef = db.collection("analyticsSummary").doc("global");

  const updates = {};

  // String fields
  updates[`genderIdentityCount.${getFieldValue(data.genderIdentity)}`] = FieldValue.increment(1);
  updates[`cityCount.${getFieldValue(data.city)}`] = FieldValue.increment(1);
  updates[`civilStatusCount.${getFieldValue(data.civilStatus)}`] = FieldValue.increment(1);
  updates[`educationLevelCount.${getFieldValue(data.educationLevel)}`] = FieldValue.increment(1);
  updates[`ageRangeCount.${getFieldValue(data.ageRange)}`] = FieldValue.increment(1);
  updates[`barangayCount.${getFieldValue(data.barangay)}`] = FieldValue.increment(1);

  // Boolean fields
  updates[`diagnosedSTICount.${getFieldValue(data.diagnosedSTI, "false")}`] = FieldValue.increment(1);
  updates[`hasHepatitisCount.${getFieldValue(data.hasHepatitis, "false")}`] = FieldValue.increment(1);
  updates[`hasTuberculosisCount.${getFieldValue(data.hasTuberculosis, "false")}`] = FieldValue.increment(1);
  updates[`hasMultiplePartnerRiskCount.${getFieldValue(data.hasMultiplePartnerRisk, "false")}`] = FieldValue.increment(1);
  updates[`isOFWCount.${getFieldValue(data.isOFW, "false")}`] = FieldValue.increment(1);
  updates[`isPregnantCount.${getFieldValue(data.isPregnant, "false")}`] = FieldValue.increment(1);
  updates[`isStudyingCount.${getFieldValue(data.isStudying, "false")}`] = FieldValue.increment(1);
  updates[`livingWithPartnerCount.${getFieldValue(data.livingWithPartner, "false")}`] = FieldValue.increment(1);
  updates[`motherHadHIVCount.${getFieldValue(data.motherHadHIV, "false")}`] = FieldValue.increment(1);

  // Always increment total users
  updates.totalUsers = FieldValue.increment(1);

  // Audit
  updates.lastUpdated = FieldValue.serverTimestamp();

  await analyticsRef.set(updates, {merge: true});
});
