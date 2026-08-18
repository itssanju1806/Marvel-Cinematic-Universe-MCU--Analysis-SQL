# 🦸‍♂️ Marvel MCU Content & Rating Analysis | SQL Portfolio Project

![SQL](https://img.shields.io/badge/SQL-Server-blue?style=for-the-badge&logo=microsoftsqlserver)
![Database](https://img.shields.io/badge/Database-Microsoft%20SQL%20Server-red?style=for-the-badge)
![Tool](https://img.shields.io/badge/Tool-SSMS-lightgrey?style=for-the-badge)
![Analysis](https://img.shields.io/badge/Analysis-Business%20Analysis-gold?style=for-the-badge)

## 📌 Project Overview

The **Marvel MCU Content & Rating Analysis** is an end-to-end **SQL Business Analysis portfolio project** focused on transforming Marvel content data into structured, business-ready insights.

The project analyzes Marvel's content portfolio across multiple dimensions, including:

- Content volume and composition
- Release trends and production growth
- Marvel universe distribution
- MCU vs non-MCU content
- Movies vs TV Series
- Live-action vs animated content
- Ratings across multiple platforms
- Cross-source rating performance
- Content volume vs rating performance
- Release-period performance
- Cast participation and recurring talent
- Cross-universe actor presence
- Universe-level cast diversity

The analysis follows a **progressive business-analysis approach**, moving from foundational descriptive analysis to comparative, trend-based, performance-oriented, and multi-table analysis.

---

## 🎯 Business Objective

To analyze Marvel's content portfolio, rating performance, release trends, universes, and cast presence using SQL to uncover meaningful business insights and performance patterns.

### Key Objectives

- Analyze Marvel's overall content portfolio and its evolution over time.
- Evaluate content performance across Marvel universes and content types.
- Compare ratings across multiple platforms using a standardized rating scale.
- Identify high-performing and underperforming content segments.
- Examine trends across release periods, animation, and MCU classification.
- Assess the relationship between content volume and rating performance.
- Analyze cast participation and identify recurring Marvel talent.
- Evaluate cross-universe actor presence and cast diversity.
- Generate data-driven insights to better understand Marvel's content strategy.

---

## 🧩 Business Problems

The analysis was designed to answer important business-oriented questions around Marvel's content strategy and performance:

1. How large is Marvel's content portfolio and how is it distributed?
2. How has Marvel's content production evolved over time?
3. Which Marvel universes contribute the most content?
4. How does the MCU compare with non-MCU content?
5. How do movies and TV Series differ across Marvel universes?
6. How does content type relate to rating performance?
7. Which Marvel universes demonstrate the strongest rating performance?
8. How consistent are ratings across different platforms?
9. Does higher content volume translate into stronger ratings?
10. How has Marvel's content performance evolved across release periods?
11. Which Marvel titles demonstrate exceptional rating performance?
12. How does the Marvel cast ecosystem contribute to the overall portfolio?

---

# ❓ Business Questions

The analysis was structured into **52 business questions** across three progressive stages.

## 01. Basic Business Analysis — Q1–Q18

### Catalog & Content Overview

1. How many Marvel titles are present in the dataset, and how are they distributed between movies and TV series?
2. How many Marvel titles were released in each year, and which years had the highest content output?
3. How is Marvel content distributed across different decades?
4. How is Marvel content distributed across the different universes?
5. How many Marvel titles are MCU canon compared with non-MCU canon?
6. How is Marvel content distributed between live-action and animated titles?
7. How many movies and TV series exist within each Marvel universe?
8. Which Marvel universes have produced the highest number of movies?
9. Which Marvel universes have produced the highest number of TV series?
10. How has the balance between movies and TV series changed over time?

### Ratings

11. How many ratings are available from each rating source?
12. What is the average rating for Marvel content across each rating source?
13. Which Marvel titles have the highest ratings according to each rating source?
14. Which Marvel titles have the lowest ratings according to each rating source?
15. How many Marvel titles are rated by each rating source, and what percentage of the total Marvel catalog does each source cover?

### Portfolio Classification

16. How is the Marvel content catalog distributed across different universes?
17. How is Marvel content distributed across MCU and non-MCU universes?
18. How is Marvel content distributed between animated and non-animated titles?

---

## 02. Intermediate Business Analysis — Q19–Q38

### Content Performance & Trends

19. Which Marvel universes have the highest average number of titles released per year?
20. Which Marvel universe has experienced the greatest growth in content production over time?
21. How does Marvel content production differ between MCU and non-MCU titles across different periods?
22. Which decades experienced the strongest growth in Marvel content production?
23. How does the movie-to-TV-series ratio differ across Marvel universes?

### Content Type & Ratings

24. Do Marvel movies or TV series have higher average ratings?
25. Do animated or non-animated titles have higher average ratings?
26. Which Marvel universe has the highest average rating based on available ratings?
27. Which Marvel universe has the lowest average rating based on available ratings?
28. How does rating coverage differ between movies and TV series?
29. How does rating coverage differ between MCU and non-MCU content?

### Universe & Content Performance

30. Which Marvel universe has the strongest combination of content volume and average rating?
31. Which Marvel universe has a high content volume but relatively low average rating?
32. Which Marvel universe has a low content volume but relatively high average rating?
33. How does MCU canon content compare with non-MCU content in terms of average ratings?
34. How does animated Marvel content compare with non-animated content in terms of content volume and ratings?

### Release & Rating Trends

35. How has the average rating of Marvel content changed over the years?
36. Which release years produced the highest-rated Marvel content?
37. Which release years produced the lowest-rated Marvel content?
38. Does rating performance differ between older and newer Marvel content?

---

## 03. Advanced Business Analysis — Q39–Q52

### Advanced Rating Analysis

39. Which Marvel titles consistently rank among the highest-rated across multiple rating sources?
40. Which Marvel titles have the largest differences between their ratings across different sources?
41. Which Marvel titles have strong ratings on one platform but relatively weak ratings on another?
42. Which Marvel universe has the strongest cross-source rating performance?
43. Which Marvel universe shows the greatest variation in ratings across sources?

### Advanced Content Performance

44. Which Marvel universes have high content volume but below-average ratings?
45. Which Marvel titles have low ratings despite having ratings available from multiple sources?
46. Which Marvel universes produce the most consistently high-rated content?
47. Which release periods produced the strongest combination of Marvel content volume and ratings?
48. Which content type — Movie or TV Series — has the strongest overall performance when considering both volume and ratings?

### Advanced Cast Analysis

49. Which actors have the strongest recurring presence across Marvel titles?
50. Which actors appear across multiple Marvel universes?
51. Which actors are associated with highly rated Marvel content?
52. Which Marvel universes have the broadest cast ecosystem?

---

# 🗂️ Data Preparation & Structure

Before beginning Business Analysis, the project underwent dedicated **data auditing and cleaning**.

The cleaned data was organized into three validated analytical tables:

### `marvel_master_clean`

Core Marvel title-level information including:

- Title
- Release year
- Marvel universe
- Content type
- MCU / canon classification
- Animation status

### `marvel_ratings_clean`

Rating information collected across multiple rating sources, enabling:

- Source-level rating analysis
- Rating comparisons
- Cross-source performance analysis
- Rating normalization

### `marvel_cast_clean`

Cast and actor-level information associated with Marvel titles, enabling:

- Actor participation analysis
- Recurring actor analysis
- Cross-universe actor analysis
- Cast ecosystem analysis

These tables provide separate but connected analytical perspectives, enabling both single-table and multi-table SQL analysis.

---

# 🔄 Project Workflow

    Raw Marvel Dataset
           ↓
    Data Import into SQL Server
           ↓
    Data Auditing & Cleaning
           ↓
    Creation of Validated Analytical Tables
           ↓
    marvel_master_clean
    marvel_ratings_clean
    marvel_cast_clean
           ↓
    Business Problem Identification
           ↓
    Basic Business Analysis
           ↓
    Intermediate Business Analysis
           ↓
    Advanced Business Analysis
           ↓
    SQL Result Validation
           ↓
    Key Insights & Business Impact
           ↓
    Recommendations
           ↓
    Portfolio Presentation

---

# 📊 Analytical Approach

The project was intentionally structured into three progressive stages.

## 01 — Basic Business Analysis

Established the foundation by analyzing:

- Catalog size and composition
- Movies vs TV Series
- Content by year and decade
- Marvel universe distribution
- MCU vs non-MCU content
- Animated vs non-animated content
- Rating availability
- Average, highest, and lowest ratings

## 02 — Intermediate Business Analysis

Moved beyond simple counts into:

- Content production trends
- Universe-level performance
- Movie vs TV Series comparisons
- Animated vs non-animated rating comparisons
- MCU vs non-MCU performance
- Rating coverage comparisons
- Release-year rating trends
- Older vs newer content performance

## 03 — Advanced Business Analysis

Focused on:

- Highest-rated Marvel titles
- Cross-source rating differences
- Rating benchmarks
- Universe-level rating performance
- Content volume vs rating performance
- High-volume, low-performing segments
- Movie vs TV Series performance
- Animated vs non-animated performance
- Release-period performance
- Cross-universe actor presence
- Recurring actor participation
- Cast ecosystem analysis

---

# ⭐ Key Insights

### 01. MCU Dominates Marvel's Content Portfolio

The MCU accounts for **54.7% of the entire Marvel content catalog**, making it the largest universe by a significant margin.

**Source: Q1, Q6**

### 02. Marvel's Content Production Exploded in the 2010s

Marvel's content output increased by **222.7% from the 2000s to the 2010s**, reaching **71 titles** — the highest volume of any decade.

**Source: Q11, Q21**

### 03. 2018 Was Marvel's Peak Production Year

2018 recorded the highest annual content output with **13 titles**, followed by 2017 with 12.

**Source: Q10, Q22**

### 04. MCU Combines Scale with Strong Performance

The MCU has both the largest content portfolio at **88 titles** and the highest average normalized rating at **6.99** among Marvel universes.

**Source: Q42, Q43**

### 05. The 2010s Were Marvel's Strongest Era

The 2010s delivered Marvel's strongest combination of scale and reception, with **71 titles** and an average normalized rating of **7.12**.

**Source: Q47**

### 06. Newer Marvel Content Consistently Outperforms Older Content

Newer content achieved higher average ratings across every major platform, with Rotten Tomatoes showing the largest improvement — from **62.53 to 71.97**.

**Source: Q38**

### 07. Rating Perception Can Vary Dramatically Across Platforms

Some Marvel titles show rating gaps approaching **5 points** between their highest and lowest normalized scores.

**Source: Q40**

### 08. Spider-Verse Leads Marvel's Highest-Rated Content

*Spider-Man: Into the Spider-Verse* and *Spider-Man: Across the Spider-Verse* occupy the top two positions among the highest-rated Marvel titles, with normalized ratings of **8.80 and 8.74**.

**Source: Q39**

### 09. Netflix Marvel Has a Distinctly TV-Driven Strategy

Netflix Marvel contains **12 TV Series versus just 1 movie**, resulting in a **0.08 movie-to-TV ratio**.

**Source: Q24**

### 10. High Content Volume Does Not Guarantee Strong Ratings

Pre-MCU and Netflix Marvel fall below the overall normalized rating benchmark despite having substantial content portfolios.

**Source: Q44**

### 11. A Small Group of Actors Connects Multiple Marvel Universes

**Nicolas Cage and Oscar Isaac** have appeared across three Marvel universes, demonstrating how select talent can bridge otherwise distinct Marvel properties.

**Source: Q50**

### 12. MCU Has the Broadest Cast Ecosystem

The MCU has **552 unique actors** in the analyzed cast data — far more than any other Marvel universe.

**Source: Q52**

### 13. Chris Evans Has the Strongest Recurring Marvel Presence

Chris Evans appears in the highest number of distinct Marvel titles, with **10 appearances**, followed by Robert Downey Jr. and Samuel L. Jackson with 9 each.

**Source: Q49**

### 14. MCU Movies Outperform MCU Series on Ratings

Within the MCU, movies achieve a higher average normalized rating of **7.01**, compared with **6.78** for TV Series.

**Source: Q48**

---

# 💡 Business Recommendations

Based on the analytical findings, the following recommendations can be considered:

1. **Balance Content Expansion with Quality**  
   Monitor whether increased production volume continues to be accompanied by strong audience and critical reception.

2. **Prioritize High-Performing Content Segments**  
   Identify successful universes, content types, and release periods that can inform future content strategy.

3. **Investigate High-Volume, Low-Performance Segments**  
   Review areas where substantial content investment is not translating into strong ratings.

4. **Use Cross-Platform Ratings Holistically**  
   Consider multiple rating sources rather than relying on a single platform when evaluating content performance.

5. **Leverage Proven Talent**  
   Analyze recurring and cross-universe talent to identify opportunities for successful actor-franchise combinations.

6. **Track Portfolio Performance Continuously**  
   Monitor content volume, ratings, universe performance, and cast trends as the Marvel portfolio evolves.

---

# 🛠️ SQL Skills Demonstrated

## Data Retrieval & Filtering

- `SELECT`
- `WHERE`
- `DISTINCT`
- Conditional filtering

## Aggregation

- `COUNT()`
- `COUNT(DISTINCT)`
- `SUM()`
- `AVG()`
- `MIN()`
- `MAX()`

## Grouping & Sorting

- `GROUP BY`
- `ORDER BY`

## Conditional Logic & Transformation

- `CASE`
- `TRY_CAST()`
- Rating normalization
- Derived analytical categories

## Multi-Table Analysis

- `INNER JOIN`
- `CROSS JOIN`
- Multi-table relational analysis

## Advanced SQL

- Common Table Expressions (`CTEs`)
- Window Functions
- `ROW_NUMBER()`
- `LAG()`
- `LEAD()`
- Ranking logic
- Comparative analysis

## Business Analysis Techniques

- Benchmark Analysis
- Trend Analysis
- Segmentation
- Comparative Analysis
- Period Comparison
- Volume vs Rating Analysis
- Cross-Source Analysis
- Outlier / variation analysis

## Data Preparation

- Data auditing
- Data cleaning
- Data validation
- Data type handling
- Structured analytical table creation

---

# 📈 Rating Normalization

A key analytical challenge was that different rating platforms use different scoring scales.

To enable meaningful comparisons, ratings were standardized to a common **10-point scale**.

### Normalization Approach

- **IMDb** → Already on a 10-point scale
- **TMDB** → Already on a 10-point scale
- **Rotten Tomatoes** → Converted from percentage scale to 10-point scale
- **Metacritic** → Converted from 100-point scale to 10-point scale

This allowed the project to compare ratings across different platforms using a consistent scale.

---

# 📌 Key Analysis Areas

### 🎬 Content Portfolio
Analyze Marvel's catalog size, composition, universes, content types, and MCU classification.

### 📅 Release Trends
Understand Marvel's production growth across years, decades, and release periods.

### 🌌 Universe Performance
Compare content volume and rating performance across Marvel universes.

### ⭐ Rating Analysis
Evaluate average ratings, highest-rated titles, rating benchmarks, and cross-platform differences.

### 🎞️ Content Type Analysis
Compare Movies vs TV Series and Animated vs Non-Animated content.

### 📊 Volume vs Performance
Identify universes and segments where content volume aligns — or does not align — with rating performance.

### 🧑‍🤝‍🧑 Cast Analysis
Identify recurring actors, cross-universe talent, and the breadth of Marvel's cast ecosystem.

---

# 📂 Repository Structure

    Marvel-MCU-SQL-Analysis/
    │
    ├── 📂 Datasets/
    │   ├── marvel_master.csv
    │   ├── marvel_ratings.csv
    │   └── marvel_cast.csv
    │
    ├── 📂 SQL/
    │   ├── 01_Database_Setup.sql
    │   ├── 01_Database_Setup.sql
    │   ├── 03_Data_Audit.sql
    │   ├── 04_DataType_and_Value_Validation.sql
    │   ├── 05_Data_Cleaning.sql
    │   └── 06_Basic_Business_Analysis.sql
    │   └── 07_Intermediate_Business_Analysis.sql
    │   └── 08_Advanced_Business_Analysis.sql
    │
    ├── 📂 Reports/
    │   ├── Dataset Audit Summary.pdf
    │   ├── Dataset Cleaning Summary.pdf
    │   ├── Executive Summary MCU.pdf
    │   └── Marvel SQL Analysis
    │
    └── 📄 README.md

---

# 🚀 Project Highlights

- Built an end-to-end **SQL Server Marvel content analysis**.
- Created and validated **3 analytical tables**.
- Structured the analysis into **Basic, Intermediate, and Advanced Business Analysis**.
- Answered **52 structured business questions**.
- Analyzed Marvel's content portfolio across multiple dimensions.
- Evaluated content production trends across years and decades.
- Compared Marvel universes and MCU vs non-MCU content.
- Compared Movies vs TV Series and Animated vs Non-Animated content.
- Standardized ratings across multiple rating platforms.
- Performed cross-source rating comparisons.
- Analyzed content volume against rating performance.
- Identified high-performing and underperforming content segments.
- Performed release-period performance analysis.
- Analyzed recurring Marvel actors.
- Identified actors appearing across multiple Marvel universes.
- Evaluated universe-level cast diversity.
- Transformed SQL outputs into business insights and recommendations.
- Presented the final analysis through a professional portfolio presentation.

---

# 🎯 Project Outcome

## From Raw Marvel Data to Business Insights

This project transformed a raw Marvel content dataset into a structured analytical framework capable of answering **52 business questions** across Basic, Intermediate, and Advanced analysis.

The project demonstrates the ability to:

- Prepare and validate relational data for analysis.
- Analyze a large entertainment content portfolio through SQL.
- Move from descriptive statistics to comparative and performance analysis.
- Combine multiple analytical tables using SQL joins.
- Normalize ratings across different scoring systems.
- Identify meaningful relationships between content volume and performance.
- Analyze both content-level and cast-level patterns.
- Convert technical SQL outputs into clear business insights.
- Develop data-driven recommendations based on analytical findings.

The overall project demonstrates how SQL can be used not only for querying data, but also for **structured business problem-solving and analytical storytelling**.

---

# 🏁 Conclusion

The **Marvel MCU Content & Rating Analysis** demonstrates an end-to-end approach to SQL-based business analysis.

Starting with foundational portfolio analysis, the project progressively moved into content trends, universe comparisons, rating performance, cross-platform benchmarking, temporal analysis, and cast-level insights.

The analysis ultimately transformed Marvel's complex content ecosystem into a structured set of **business insights, performance patterns, and strategic recommendations**.

The project showcases practical SQL capabilities while maintaining a strong focus on **business thinking, analytical reasoning, data interpretation, and actionable insights**.

---

# 👨‍💻 About the Project

**Project Type:** SQL Portfolio Project  
**Domain:** Entertainment / Media Analytics  
**Database:** Microsoft SQL Server  
**Environment:** SQL Server Management Studio (SSMS)  
**Analysis Type:** Business & Exploratory Data Analysis  
**Business Questions:** 52  
**Analytical Tables:** 3

---

# 👨‍💻 About Me

**Sanjay Singh**  
Data Analyst | SQL | Excel | Power BI | Python

I am building a portfolio of practical data analytics projects focused on solving business problems through **data analysis, visualization, and actionable insights**.

This project represents my hands-on experience in using **SQL to analyze relational entertainment data, perform multi-dimensional business analysis, and translate analytical results into meaningful business recommendations**.

---

# ⭐ Explore the Project

If you found this project useful or interesting:

⭐ **Star this repository**  
🍴 **Fork the repository**  
💼 **Connect with me on LinkedIn**  
📂 **Explore my other Data Analytics projects**

---

# 📬 Let's Connect

**Sanjay Singh**

📧 Email: *singhsanjay846@gmail.com*  
💼 LinkedIn: https://www.linkedin.com/in/sanjay-singh-509aa7135  
🐙 GitHub: https://github.com/itssanju1806

I'm always open to connecting with fellow data enthusiasts, analysts, recruiters, and professionals working in the analytics space.

**Thanks for visiting this project!** 🚀🦸‍♂️
