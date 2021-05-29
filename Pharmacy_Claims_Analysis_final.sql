use pharmacy_claims;

select * from dim_drug;
select * from dim_drugbrand;
select * from dim_drugform;
select * from dim_member;
select * from fact_insurance;


# PART 2 - Modifying Datatype

alter table dim_drug
modify column drug_ndc varchar(100);

alter table dim_drug
modify column drug_form_code varchar(100);

alter table dim_drug
modify column drug_brand_generic_code varchar(100);

alter table dim_drugform
modify column drug_form_code varchar(100);

alter table dim_drugbrand
modify column drug_brand_generic_code varchar(100);

alter table fact_insurance
modify member_id varchar(100);

alter table fact_insurance
modify drug_ndc varchar(100);

alter table dim_member
modify member_id varchar(100);


# Assigning Primary Keys

alter table dim_drug
add primary key (drug_ndc);

alter table dim_drugbrand
add primary key (drug_brand_generic_code);

alter table dim_drugform
add primary key (drug_form_code);

alter table dim_member
add primary key (member_id);

# Assigning Surrogate keys

alter table fact_insurance
add FIN int not null auto_increment primary key;

# Assigning Foreign Keys

alter table dim_drug
add foreign key drug_form_foreign(drug_form_code) 
references dim_drugform(drug_form_code)
on delete restrict
on update restrict;

alter table dim_drug
add foreign key drug_brand_foreign(drug_brand_generic_code) 
references dim_drugbrand(drug_brand_generic_code)
on delete restrict
on update restrict;

alter table fact_insurance
add foreign key memberid_foreign(member_id) 
references dim_member(member_id)
on delete restrict
on update restrict;

alter table fact_insurance
add foreign key drug_ndc_foreign(drug_ndc) 
references dim_drug(drug_ndc)
on delete restrict
on update restrict;


# PART 4

# 1
select drug_name as DRUG_NAME, count(*) as No_Of_Prescriptions
from dim_drug
inner join fact_insurance f on dim_drug.drug_ndc = f.drug_ndc
group by drug_name
order by No_Of_Prescriptions desc;

# 2
select count(fact_insurance.FIN) as Total_Prescriptions, count(distinct fact_insurance.member_id) as Distinct_Members, sum(fact_insurance.copay) as Total_Copay, sum(fact_insurance.insurancepaid) as Total_Insurance,
case when dim_member.member_age > 65 then "Aged 65+"
when dim_member.member_age < 65 then "Aged < 65"
end as age_category
from fact_insurance
inner join dim_member on fact_insurance.member_id = dim_member.member_id
group by age_category;

# 3
select i.member_id as member_id, i.member_first_name as member_first_name, i.member_last_name as member_last_name, i.drug_name, i.fill_date as fill_date,
i.insurancepaid as recent_insurance_paid
from
	( select
		dm1.member_id, dm1.member_last_name, dm1.member_first_name, dd.drug_name, fi1.fill_date, fi1.insurancepaid,
lead(fill_date) over(partition by dm1.member_id order by member_first_name, fill_date desc),
lead(insurancepaid) over(partition by dm1.member_id order by member_first_name, fill_date desc),
row_number() over (partition by dm1.member_id) as flag
from fact_insurance fi1
        inner join dim_member dm1
        on fi1.member_id=dm1.member_id
        inner join dim_drug dd
        on fi1.drug_ndc=dd.drug_ndc
	) as i
    where flag = 1;

