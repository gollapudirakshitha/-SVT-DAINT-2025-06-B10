### Top 5 districts with highest number of professional colleges

**Query:**

```sql
SELECT District, COUNT(DISTINCT `College Name`) AS CollegeCount
FROM dataset
WHERE `Is Professional` = 'Professional Course'
GROUP BY District
ORDER BY CollegeCount DESC
LIMIT 5;
```

### Average course duration per course type

**Query:**

```sql
SELECT `Course Type`, ROUND(AVG(`Course Duration (In months)`), 2) AS AvgDuration
FROM dataset
GROUP BY `Course Type`
ORDER BY AvgDuration DESC;
```

### Unique colleges offering each course category

**Query:**

```sql
SELECT `Course Category`, COUNT(DISTINCT `College Name`) AS CollegeCount
FROM dataset
GROUP BY `Course Category`;
```

### Colleges offering both UG and PG courses

**Query:**

```sql
SELECT DISTINCT a.`College Name`
FROM dataset a
JOIN dataset b ON a.`College Name` = b.`College Name`
WHERE a.`Course Type` = 'UG' AND b.`Course Type` = 'PG';
```

### Universities with >10 unaided non-professional courses

**Query:**

```sql
SELECT University, COUNT(*) AS UnaidedNonProfCount
FROM dataset
WHERE `Course Aided Status` = 'Unaided' AND `Is Professional` = 'Non-Professional Course'
GROUP BY University
HAVING COUNT(*) > 10;
```

### Engineering colleges with high-duration courses

**Query:**

```sql
WITH avg_duration AS (
  SELECT AVG(`Course Duration (In months)`) AS avg_val
  FROM dataset
  WHERE `Course Category` = 'Engineering'
)
SELECT *
FROM dataset
WHERE `Course Category` = 'Engineering'
AND `Course Duration (In months)` > (SELECT avg_val FROM avg_duration);
```

### Rank courses within each college

**Query:**

```sql
SELECT *,
  RANK() OVER (PARTITION BY `College Name` ORDER BY `Course Duration (In months)` DESC) AS CourseRank
FROM dataset;
```

### Colleges with >24 months difference between longest & shortest courses

**Query:**

```sql
SELECT `College Name`
FROM dataset
GROUP BY `College Name`
HAVING MAX(`Course Duration (In months)`) - MIN(`Course Duration (In months)`) > 24;
```

### Cumulative professional course count by university

**Query:**

```sql
SELECT University,
       COUNT(*) AS TotalProfessionalCourses,
       SUM(COUNT(*)) OVER (ORDER BY University) AS CumulativeTotal
FROM dataset
WHERE `Is Professional` = 'Professional Course'
GROUP BY University
ORDER BY University;
```

### Colleges offering more than one course category

**Query:**

```sql
SELECT `College Name`
FROM dataset
GROUP BY `College Name`
HAVING COUNT(DISTINCT `Course Category`) > 1;
```

### Talukas above district average course duration

**Query:**

```sql
WITH district_avg AS (
  SELECT District, AVG(`Course Duration (In months)`) AS district_avg_duration
  FROM dataset
  GROUP BY District
),
  taluka_avg AS (
  SELECT District, Taluka, AVG(`Course Duration (In months)`) AS taluka_avg_duration
  FROM dataset
  GROUP BY District, Taluka
)
SELECT t.*
FROM taluka_avg t
JOIN district_avg d ON t.District = d.District
WHERE t.taluka_avg_duration > d.district_avg_duration;
```

### Classify course durations

**Query:**

```sql
SELECT `Course Category`,
       CASE
         WHEN `Course Duration (In months)` < 12 THEN 'Short'
         WHEN `Course Duration (In months)` BETWEEN 12 AND 36 THEN 'Medium'
         ELSE 'Long'
       END AS DurationType,
       COUNT(*) AS CountPerType
FROM dataset
GROUP BY `Course Category`, DurationType;
```

### Extract course specialization

**Query:**

```sql
SELECT `Course Name`,
       TRIM(SUBSTRING_INDEX(`Course Name`, '-', -1)) AS Specialization
FROM dataset
WHERE `Course Name` LIKE '%-%';
```

### Count courses with "Engineering" in the name

**Query:**

```sql
SELECT COUNT(*) AS EngineeringCourseCount
FROM dataset
WHERE `Course Name` LIKE '%Engineering%';
```

### Unique course combinations

**Query:**

```sql
SELECT DISTINCT `Course Name`, `Course Type`, `Course Category`
FROM dataset;
```

### Courses not in Government colleges

**Query:**

```sql
SELECT *
FROM dataset
WHERE `College Type` != 'Government';
```

### University with 2nd highest aided course count

**Query:**

```sql
WITH ranked AS (
  SELECT University, COUNT(*) AS AidedCourseCount,
         DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
  FROM dataset
  WHERE `Course Aided Status` = 'Aided'
  GROUP BY University
)
SELECT University, AidedCourseCount
FROM ranked
WHERE rank = 2;
```

### Courses above median duration

**Query:**

```sql
WITH ordered AS (
  SELECT `Course Duration (In months)` AS duration,
         ROW_NUMBER() OVER (ORDER BY `Course Duration (In months)`) AS rn,
         COUNT(*) OVER () AS total
  FROM dataset
  WHERE `Course Duration (In months)` IS NOT NULL
),
median AS (
  SELECT AVG(duration) AS median_val
  FROM ordered
  WHERE rn IN (FLOOR((total + 1)/2), CEIL((total + 1)/2))
)
SELECT *
FROM dataset
WHERE `Course Duration (In months)` > (SELECT median_val FROM median);
```

### % of unaided courses that are professional per university

**Query:**

```sql
SELECT University,
       ROUND(SUM(CASE WHEN `Is Professional` = 'Professional Course' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS PercentageProfessional
FROM dataset
WHERE `Course Aided Status` = 'Unaided'
GROUP BY University;
```

### Top 3 course categories by average duration

**Query:**

```sql
SELECT `Course Category`, ROUND(AVG(`Course Duration (In months)`), 2) AS AvgDuration
FROM dataset
GROUP BY `Course Category`
ORDER BY AvgDuration DESC
LIMIT 3;
```
