-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS sum_of_all_claims
FROM prescription
GROUP BY npi
ORDER BY sum_of_all_claims DESC;
-- #1881634483 had 99707 total claims. Attempt #2.  Could also be wrong.

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT npi, doc.nppes_provider_first_name, doc.nppes_provider_last_org_name, doc.specialty_description, SUM(total_claim_count) AS all_claims
FROM prescription AS drug
INNER JOIN prescriber AS doc
USING (npi)
GROUP BY drug.npi, doc.nppes_provider_first_name, doc.nppes_provider_last_org_name, doc.specialty_description
ORDER BY all_claims DESC;
-- BRUCE PENDLEY Family Practice with 99707 claims

-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT doc.specialty_description, SUM(total_claim_count) AS all_claims
FROM prescription AS drug
INNER JOIN prescriber AS doc
USING (npi)
GROUP BY doc.specialty_description
ORDER BY all_claims DESC;
-- With a total of 9,752,347, Family practice had the highest number of claims.

-- 2b. Which specialty had the most total number of claims for opioids? (opoid_drug_flag)
SELECT specialty_description AS speciality, SUM(total_claim_count) AS total_claims
FROM prescription AS rx
INNER JOIN prescriber AS doc
USING (npi)
LEFT JOIN drug
USING (drug_name)
GROUP BY speciality
ORDER BY total_claims DESC;
-- With a total of 10,398,706, Family Practice had the most total number of claims for opioids

-- 2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?