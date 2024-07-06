USE Pharmacy;


#DEFINING PRIMARY KEY
#fact_pharmacyclaims
ALTER TABLE `Pharmacy`.`fact_pharmacyclaims` 
CHANGE COLUMN `Fact_ID` `Fact_ID` INT NOT NULL AUTO_INCREMENT ,
ADD PRIMARY KEY (`Fact_ID`);
#dim_member
ALTER TABLE `Pharmacy`.`dim_member` 
CHANGE COLUMN `member_id` `member_id` varchar(100) NOT NULL ,
ADD PRIMARY KEY (`member_id`);
#dim_gender
ALTER TABLE `Pharmacy`.`dim_gender` 
CHANGE COLUMN `Gender_ID` `Gender_ID` INT NOT NULL AUTO_INCREMENT ,
ADD PRIMARY KEY (`Gender_ID`);
#dim_drugform
ALTER TABLE `Pharmacy`.`dim_drugform` 
CHANGE COLUMN `Drug_Form_ID` `Drug_Form_ID` INT NOT NULL AUTO_INCREMENT ,
ADD PRIMARY KEY (`Drug_Form_ID`);
#dim_drugbrand
ALTER TABLE `Pharmacy`.`dim_drugbrand` 
CHANGE COLUMN `Drug_Brand_ID` `Drug_Brand_ID` INT NOT NULL AUTO_INCREMENT ,
ADD PRIMARY KEY (`Drug_Brand_ID`);
#dim_drug
ALTER TABLE `Pharmacy`.`dim_drug` 
CHANGE COLUMN `Drug_ID` `Drug_ID` INT NOT NULL AUTO_INCREMENT ,
ADD PRIMARY KEY (`Drug_ID`);


#DEFINING FOREIGN KEY
ALTER TABLE `Pharmacy`.`fact_pharmacyclaims` 
ADD FOREIGN KEY Drug_ID(Drug_ID)
REFERENCES dim_drug(Drug_ID)
ON DELETE RESTRICT
ON UPDATE RESTRICT;
ALTER TABLE `Pharmacy`.`fact_pharmacyclaims` 
ADD FOREIGN KEY Member_ID(Member_ID)
REFERENCES dim_member(member_id)
ON DELETE CASCADE
ON UPDATE CASCADE;
ALTER TABLE `Pharmacy`.`dim_member` 
ADD FOREIGN KEY Gender_ID(Gender_ID)
REFERENCES dim_gender(Gender_ID)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE `Pharmacy`.`dim_drug` 
ADD FOREIGN KEY Drug_From_ID(Drug_Form_ID)
REFERENCES dim_drugform(Drug_Form_ID)
ON DELETE SET NULL
ON UPDATE SET NULL;

ALTER TABLE `Pharmacy`.`dim_drug` 
ADD FOREIGN KEY Drug_Brand_ID(Drug_Brand_ID)
REFERENCES dim_drugbrand(Drug_Brand_ID)
ON DELETE SET NULL
ON UPDATE SET NULL;


#PART 4 1
#-	Write a SQL query that identifies the number of prescriptions grouped by drug name. 
Select d.drug_name, count(*)
From dim_Drug d
Inner join fact_PharmacyClaims p on d.Drug_ID=p.Drug_ID
Group by d.drug_name;
#- How many prescriptions were filled for the drug Ambien?
Select count(*)
From dim_Drug d
Inner join fact_PharmacyClaims p on d.Drug_ID=p.Drug_ID
Where d.drug_name='Ambien';


# PART 4 2
#SQL query that counts total prescriptions, counts unique (i.e. distinct) members, sums copay $$, and sums insurance paid $$, for members grouped as either ‘age 65+’ or ’ < 65’
with cte as(
select
p.Fact_ID fact_id, 
m.member_id member_id, 
p.copay copay, 
p.insurancePaid insurancepaid, 
case when m.member_age>=65 then 'age 65+' else '<65' end AgeGroup
from fact_pharmacyclaims p
inner join dim_member m on p.Member_ID=m.member_id
inner join dim_drug d on d.Drug_ID=p.Drug_ID
)

select 
AgeGroup,
count(*) Total_Prescriptions, 
count(distinct member_ID) Total_Members, 
sum(copay) Sum_Copay, 
sum(insurancePaid) Sum_Insurance
from cte c
group by AgeGroup;



# PART 4 3
#SQL query that identifies the amount paid by the insurance for the most recent prescription fill date
With cte as (
Select
m.member_id, 
m.member_first_name, 
m.member_last_name, 
d.drug_name, 
p.Fill_Date,
p.InsurancePaid,
Row_Number() Over(partition by m.member_id order by Fill_Date desc) rn
from fact_pharmacyclaims p
inner join dim_member m on p.Member_ID=m.member_ID
inner join dim_drug d on d.Drug_ID=p.Drug_ID
)
	Select
		member_id, 
member_first_name, 
member_last_name, 
drug_name, 
fill_date,
insurancepaid
from cte
where rn=1;


