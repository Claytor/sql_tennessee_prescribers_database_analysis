-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS sum_of_all_claims
FROM prescription
GROUP BY npi
ORDER BY sum_of_all_claims DESC;
-- #1881634483 had 99,707 total claims. Attempt #2.  Could also be wrong.

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
SELECT specialty_description AS specialty, 
SUM(sub.total_claim) AS total_number_claims
FROM
(SELECT drug_name, 
specialty_description, 
SUM(total_claim_count) AS total_claim
FROM prescriber as doc
INNER JOIN prescription as rx
ON doc.npi = rx.npi
GROUP BY drug_name, specialty_description) AS sub
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y' 
GROUP BY specialty_description
ORDER BY total_number_claims DESC; 
-- With a total of 900,845, Nurse Practitioner had the most total number of claims for opioids.

-- 2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT 
	specialty_description,
	COUNT (total_claim_count)
FROM prescriber
LEFT JOIN prescription
USING(npi) 
GROUP BY specialty_description
HAVING COUNT(total_claim_count) = 0
ORDER BY specialty_description;
-- There are 15 specialties that have no associations in the prescription table.

-- 3a. Which drug (generic_name) had the highest total drug cost?
SELECT
	generic_name,
	SUM(total_drug_cost) ::money AS total_cost
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC;
--With a cost of $104,264,066.35, "INSULIN GLARGINE,HUM.REC.ANLOG" had the highest toal cost.

-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT
	generic_name,
	SUM(total_drug_cost) ::money AS total_cost,
	SUM(total_day_supply) AS total_supply,
	SUM(total_drug_cost)::money / SUM(total_day_supply) as cost_per_day
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;
-- With a daily cost of $3,495.22, C1 ESTERASE INHIBITOR is the most expensive.

-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT
	drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opoid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' 
	END AS drug_type
FROM drug
ORDER BY drug_type DESC;

-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
	(CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 'opioid' 
	 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' ELSE 'neither' END) AS drug_type, 
	 SUM(total_drug_cost) AS total_cost 
FROM drug INNER JOIN prescription USING(drug_name)
GROUP BY 
	(CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 'opioid' WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' ELSE 'neither' END) ORDER BY total_cost DESC; 

-- 5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(cbsa) 
FROM cbsa WHERE cbsaname LIKE '%TN';
-- There are 33 CBSAs in Tennessee.

-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population. 
SELECT cbsaname, SUM(population) AS total_population 
FROM cbsa 
INNER JOIN population 
USING(fipscounty) GROUP BY cbsaname 
ORDER BY total_population DESC; 
-- "Nashville-Davidson--Murfreesboro--Franklin, TN" has the largest combined population. "Morristown, TN"
   
-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, population 
FROM fips_county 
INNER JOIN population 
USING(fipscounty) 
WHERE fipscounty 
NOT IN 
	(SELECT fipscounty 
	 FROM cbsa) 
GROUP BY county, population 
ORDER BY population DESC;
-- With a population 95,523, of SEVIER county is the largest populated county that is not includen in a CBSA.

-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name AS drug, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

-- 6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, total_claim_count, opioid_drug_flag AS opioid
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count >= 3000
AND opioid_drug_flag = 'Y' OR opioid_drug_flag = 'N'
ORDER BY opioid DESC; 
   
-- 6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name, total_claim_count, opioid_drug_flag AS opioid, nppes_provider_last_org_name, nppes_provider_first_name
FROM prescription 
LEFT JOIN prescriber 
USING(npi)
LEFT JOIN drug 
USING(drug_name)
WHERE total_claim_count >= 3000
AND opioid_drug_flag = 'Y'OR opioid_drug_flag = 'N'
ORDER BY opioid DESC
LIMIT 10; 

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
   
-- 7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber, drug
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
   
-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
   
-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.