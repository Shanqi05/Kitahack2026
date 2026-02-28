# JSON Data Configuration Guide

## Overview

This guide explains how the JSON files work together and how to properly configure them based on the current code implementation.

---

## File Structure

The admission system uses **3 main JSON files**:

### 1. **courses.json** - Course Metadata
Contains general information about each course (course name, field, available levels)

**File Location:** `assets/data/courses.json`

**Structure:**
```json
[
  {
    "id": "CS",
    "name": "Computer Science",
    "field": "IT",
    "level": ["Diploma", "Degree", "Foundation", "Asasi"]
  },
  {
    "id": "MECH",
    "name": "Mechanical Engineering",
    "field": "Engineering",
    "level": ["Degree", "Foundation", "Asasi"]
  }
]
```

**Fields:**
- `id` - Unique course identifier (used as reference in program_offerings.json)
- `name` - Full course name (displayed to students)
- `field` - Subject field/category
- `level` - Array of available levels for this course

**⚠️ IMPORTANT:** This file is **REQUIRED** and cannot be deleted. The code uses it to look up course names and fields.

---

### 2. **program_offerings.json** - University Programs
Contains specific program offerings by universities with admission requirements

**File Location:** `assets/data/program_offerings.json`

**Structure:**
```json
[
  {
    "university_id": "UM",
    "course_id": "CS",
    "level": "Degree",
    "entry_mode": ["STPM", "Matrikulasi", "Asasi", "Diploma"],
    "min_merit": 92,
    "annual_fee": 8000,
    "interest_field": "IT"
  },
  {
    "university_id": "TAY",
    "course_id": "CS_FOUND",
    "level": "Foundation",
    "entry_mode": ["SPM_Direct"],
    "min_merit": null,
    "annual_fee": 40000,
    "interest_field": "IT"
  }
]
```

**Required Fields:**

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `university_id` | String | University code | "UM", "TAY", "HELP" |
| `course_id` | String | Course identifier (must match courses.json id) | "CS", "MECH", "ASASI_IT" |
| `level` | String | Program level | "Degree", "Diploma", "Asasi", "Foundation" |
| `entry_mode` | Array | Admission pathways this program accepts | `["SPM_UPU"]`, `["SPM_Direct"]`, `["STPM", "Matrikulasi", "Asasi", "Diploma"]` |
| `min_merit` | Number or null | Minimum merit requirement (for public unis) | 85, 90, or `null` for private |
| `annual_fee` | Number | Annual tuition fee in RM | 8000, 30000, 40000 |
| `interest_field` | String | Subject field for matching | "IT", "Engineering", "Business", "Science", etc |

---
interest field
1. IT (Information Technology)
2. AI (Artificial Intelligence)
3. Data Science
4. Engineering
5. Business
6. Finance
7. Health Science
8. Psychology
9. Science
10. Communication
11. Arts
12. Law

### 3. **universities.json** - University Information
Contains general university information

**File Location:** `assets/data/universities.json`

**Structure:**
```json
[
  {
    "id": "UM",
    "name": "University of Malaya",
    "location": "Kuala Lumpur",
    "website": "www.um.edu.my",
    "type": "Public"
  },
  {
    "id": "TAY",
    "name": "Taylor's University",
    "location": "Subang Jaya",
    "website": "www.taylors.edu.my",
    "type": "Private"
  }
]
```

---

## Entry Mode Configuration

The `entry_mode` field in program_offerings.json determines which admission pathway can access this program.

### Valid Entry Modes:

**For SPM Students via UPU (Public Universities only):**
```json
"entry_mode": ["SPM_UPU"]
```
✅ Use for: **Asasi** and **Diploma** courses at public universities
- Returns: 2 types of courses (Asasi + Diploma)

**For SPM Students via Direct Entry (Private Universities only):**
```json
"entry_mode": ["SPM_Direct"]
```
✅ Use for: **Foundation** courses at private universities
- Returns: Foundation courses only

**For Post-Secondary Students via UPU (Public Universities):**
```json
"entry_mode": ["STPM_UPU", "Matrikulasi_UPU", "Asasi_UPU", "Diploma_UPU"]
```
✅ Use for: **Degree** courses at public universities
- For students with STPM, Matrikulasi, Asasi, or Diploma qualifications
- Returns: Degree courses from PUBLIC universities only

**For Post-Secondary Students via Direct (Private Universities):**
```json
"entry_mode": ["STPM_Direct", "Matrikulasi_Direct", "Asasi_Direct", "Diploma_Direct"]
```
✅ Use for: **Degree** courses at private universities
- For students with STPM, Matrikulasi, Asasi, or Diploma qualifications
- Returns: Degree courses from PRIVATE universities only

---

## Three Admission Pathways

### Pathway 1: SPM via UPU (Public Universities)

**Student Qualification:** SPM + UPU = TRUE

**Returns 3 Courses:**
1. Top-ranked **Asasi** program
2. Top-ranked **Diploma** program

```json
// For Asasi courses (public unis)
{
  "university_id": "UM",
  "course_id": "ASASI_IT",
  "level": "Asasi",
  "entry_mode": ["SPM_UPU"],
  "min_merit": null,
  "annual_fee": 6500,
  "interest_field": "IT"
},

// For Diploma courses (public unis)
{
  "university_id": "UM",
  "course_id": "IT_DIPLOMA",
  "level": "Diploma",
  "entry_mode": ["SPM_UPU"],
  "min_merit": 75,
  "annual_fee": 7500,
  "interest_field": "IT"
}
```

---

### Pathway 2: SPM Direct Entry (Private Universities)

**Student Qualification:** SPM + UPU = FALSE (Direct/Private admission)

**Returns 3 Courses:**
1. Top-ranked **Foundation** program 1
2. Top-ranked **Foundation** program 2
3. Top-ranked **Foundation** program 3

```json
// For Foundation courses (private unis only)
{
  "university_id": "HELP",
  "course_id": "BUS_FOUND",
  "level": "Foundation",
  "entry_mode": ["SPM_Direct"],
  "min_merit": null,
  "annual_fee": 30000,
  "interest_field": "Business"
},
{
  "university_id": "MONASH",
  "course_id": "IT_FOUND",
  "level": "Foundation",
  "entry_mode": ["SPM_Direct"],
  "min_merit": null,
  "annual_fee": 38000,
  "interest_field": "IT"
}
```

---

### Pathway 3A: STPM/Matrikulasi/Asasi/Diploma via UPU (Public Universities)

**Student Qualification:** STPM, Matrikulasi, Asasi, or Diploma + UPU = TRUE

**Returns 3 Courses:**
1. Top-ranked **Degree** program 1
2. Top-ranked **Degree** program 2
3. Top-ranked **Degree** program 3

```json
// For Degree courses at PUBLIC universities
{
  "university_id": "UM",
  "course_id": "CS",
  "level": "Degree",
  "entry_mode": ["STPM_UPU", "Matrikulasi_UPU", "Asasi_UPU", "Diploma_UPU"],
  "min_merit": 92,
  "annual_fee": 8000,
  "interest_field": "IT"
},
{
  "university_id": "USM",
  "course_id": "DS",
  "level": "Degree",
  "entry_mode": ["STPM_UPU", "Matrikulasi_UPU", "Asasi_UPU", "Diploma_UPU"],
  "min_merit": 90,
  "annual_fee": 7500,
  "interest_field": "IT"
}
```

---

### Pathway 3B: STPM/Matrikulasi/Asasi/Diploma via Direct (Private Universities)

**Student Qualification:** STPM, Matrikulasi, Asasi, or Diploma + UPU = FALSE

**Returns 3 Courses:**
1. Top-ranked **Degree** program 1
2. Top-ranked **Degree** program 2
3. Top-ranked **Degree** program 3

```json
// For Degree courses at PRIVATE universities
{
  "university_id": "TAYLOR",
  "course_id": "IT_DEGREE",
  "level": "Degree",
  "entry_mode": ["STPM_Direct", "Matrikulasi_Direct", "Asasi_Direct", "Diploma_Direct"],
  "min_merit": null,
  "annual_fee": 42000,
  "interest_field": "IT"
},
{
  "university_id": "SUNWAY",
  "course_id": "BUSINESS",
  "level": "Degree",
  "entry_mode": ["STPM_Direct", "Matrikulasi_Direct", "Asasi_Direct", "Diploma_Direct"],
  "min_merit": null,
  "annual_fee": 42000,
  "interest_field": "Business"
}
```

---

## Public vs Private Universities

### Public Universities (UPU)
Must have `entry_mode` containing:
- `["SPM_UPU"]` for Asasi/Diploma
- `["STPM_UPU", "Matrikulasi_UPU", "Asasi_UPU", "Diploma_UPU"]` for Degree

**List:**
- UM, UKM, USM, UPM, UITM, UMS, UNIMAP, UNIMAS, IIUM, UTEM

### Private Universities (Direct)
Must have `entry_mode` containing:
- `["SPM_Direct"]` for Foundation
- `["STPM_Direct", "Matrikulasi_Direct", "Asasi_Direct", "Diploma_Direct"]` for Degree
- Never use "SPM_UPU" (not applicable)

**List:**
- TAY, HELP, MONASH, SUNWAY, INTI, UCSI, TAYLOR, APU, MMU, KDU, USIM

---

## How to Update program_offerings.json

### Option 1: Using PowerShell Script (Automated)

Run this command to fix all entry_modes at once:

```powershell
cd "c:\users\user\Kitahack2026\sleepnotfound404\assets\data"

$json = Get-Content program_offerings.json -Raw | ConvertFrom-Json

$publicUnis = @('UM', 'UKM', 'USM', 'UPM', 'UITM', 'UMS', 'UNIMAP', 'UNIMAS', 'IIUM', 'UTEM')

foreach ($course in $json) {
    $uniId = $course.university_id
    $level = $course.level
    $isPublic = $uniId -in $publicUnis
    
    # Set entry_mode based on level and university type
    if ($level -eq 'Asasi' -or $level -eq 'Diploma') {
        $course.entry_mode = @('SPM_UPU')
    }
    elseif ($level -eq 'Foundation') {
        $course.entry_mode = @('SPM_Direct')
    }
    elseif ($level -eq 'Degree') {
        if ($isPublic) {
            $course.entry_mode = @('STPM_UPU', 'Matrikulasi_UPU', 'Asasi_UPU', 'Diploma_UPU')
        } else {
            $course.entry_mode = @('STPM_Direct', 'Matrikulasi_Direct', 'Asasi_Direct', 'Diploma_Direct')
        }
    }
}

$json | ConvertTo-Json -Depth 10 | Set-Content program_offerings.json
Write-Host "✅ Updated program_offerings.json with correct entry_modes!"
```

### Option 2: Manual Updates

1. Open `program_offerings.json` in VS Code
2. Find and replace all `"entry_mode": ["UPU"]` with the correct mode:
   - **Asasi/Diploma courses (all public unis)** → `"entry_mode": ["SPM_UPU"]`
   - **Foundation courses (all private unis)** → `"entry_mode": ["SPM_Direct"]`
   - **Degree courses at PUBLIC universities** (UM, UKM, USM, UPM, UITM, UMS, UNIMAP, UNIMAS, IIUM, UTEM) → `"entry_mode": ["STPM_UPU", "Matrikulasi_UPU", "Asasi_UPU", "Diploma_UPU"]`
   - **Degree courses at PRIVATE universities** (TAY, HELP, MONASH, SUNWAY, INTI, UCSI, TAYLOR, APU, MMU, KDU, USIM) → `"entry_mode": ["STPM_Direct", "Matrikulasi_Direct", "Asasi_Direct", "Diploma_Direct"]`

---

## Merging courses.json into program_offerings.json

**Question:** Can I delete courses.json and add course names directly to program_offerings.json?

**Answer:** 
- ❌ **Not recommended without code changes**
- The current code in `course_repository.dart` loads courses.json separately
- **You would need to:**
  1. Add `course_name` and other fields to program_offerings.json
  2. Update the Dart code in `admission_engine.dart` and `course_repository.dart`
  3. Remove the courses.json loading logic

**If you want to do this:**

Update program_offerings.json structure to include course details:

```json
[
  {
    "university_id": "UM",
    "course_id": "CS",
    "course_name": "Computer Science",
    "course_field": "IT",
    "level": "Degree",
    "entry_mode": ["STPM", "Matrikulasi", "Asasi", "Diploma"],
    "min_merit": 92,
    "annual_fee": 8000,
    "interest_field": "IT"
  }
]
```

Then update the code:
- Edit `lib/features/admission/data/course_repository.dart` - Remove courses.json loading
- Edit `lib/features/admission/data/admission_engine.dart` - Use course_name directly

---

## Verification Checklist

Before testing, verify:

- ✅ All Asasi courses have `"entry_mode": ["SPM_UPU"]`
- ✅ All Diploma courses have `"entry_mode": ["SPM_UPU"]`
- ✅ All Foundation courses have `"entry_mode": ["SPM_Direct"]`
- ✅ All Degree courses at PUBLIC universities have `"entry_mode": ["STPM_UPU", "Matrikulasi_UPU", "Asasi_UPU", "Diploma_UPU"]`
- ✅ All Degree courses at PRIVATE universities have `"entry_mode": ["STPM_Direct", "Matrikulasi_Direct", "Asasi_Direct", "Diploma_Direct"]`
- ✅ Public universities have min_merit set (not null) for degrees
- ✅ Private universities have min_merit as null for degrees
- ✅ All courses.json course_ids match program_offerings.json course_ids
- ✅ Each interest_field is consistent (IT, Engineering, Business, Science, etc)

---

## Testing

After updating, test each pathway:

1. **SPM UPU Path:**
   - Qualification: "SPM"
   - isUpu: true
   - Expected: Asasi + Diploma courses from PUBLIC universities only

2. **SPM Direct Path:**
   - Qualification: "SPM"
   - isUpu: false
   - Expected: Foundation courses from PRIVATE universities only

3. **Post-Secondary UPU Path:**
   - Qualification: "STPM" / "Matrikulasi" / "Asasi" / "Diploma"
   - isUpu: true
   - Expected: Degree courses from PUBLIC universities only

4. **Post-Secondary Direct Path:**
   - Qualification: "STPM" / "Matrikulasi" / "Asasi" / "Diploma"
   - isUpu: false
   - Expected: Degree courses from PRIVATE universities only

---

## Summary

| Component | Purpose | Can Delete? | Notes |
|-----------|---------|------------|-------|
| courses.json | Course metadata (name, field) | ❌ NO | Required by current code |
| program_offerings.json | University programs + admission rules | ❌ NO | Core data file |
| universities.json | University info | ✅ Optional | Can delete if not using |

---

## Troubleshooting

### Problem: Courses not showing up for a pathway

**Possible Causes:**
1. **Wrong entry_mode value** - Check that entry_mode matches one of: `SPM_UPU`, `SPM_Direct`, `STPM_UPU`, `Matrikulasi_UPU`, `Asasi_UPU`, `Diploma_UPU`, `STPM_Direct`, `Matrikulasi_Direct`, `Asasi_Direct`, `Diploma_Direct`

2. **Wrong level for pathway** - Verify:
   - SPM UPU pathway needs: "Asasi" or "Diploma" level
   - SPM Direct pathway needs: "Foundation" level
   - Post-Secondary pathways need: "Degree" level

3. **Wrong university_id** - Make sure university_id is a valid public or private university code

4. **Duplicate entry_mode values** - Ensure you're not accidentally listing the same pathway twice in the entry_mode array

### Problem: Students getting wrong course suggestions

**Solutions:**
1. Run the verification script to count courses per pathway:
   ```powershell
   $json = Get-Content program_offerings.json | ConvertFrom-Json
   $json | Group-Object {$_.entry_mode[0]} | Select Name, @{N="Count";E={$_.Group.Count}}
   ```

2. Check if courses are matching the correct level for each pathway

3. Verify entry_mode is assgined correctly using the PowerShell script

### Problem: JSON validation errors

**Solutions:**
1. Validate JSON syntax using online validator (jsonlint.com)
2. Ensure all string values are enclosed in quotes
3. Ensure array brackets are properly closed: `[ ... ]`
4. Ensure object braces are properly closed: `{ ... }`
5. No trailing commas in arrays or objects

---

## Questions?

If you have questions about the JSON structure or need custom modifications, ensure all 4 pathways return appropriate courses:
- SPM UPU → Asasi + Diploma from PUBLIC universities (max 3)
- SPM Direct → Foundation from PRIVATE universities (max 3)
- Post-Secondary UPU → Degree from PUBLIC universities (max 3)
- Post-Secondary Direct → Degree from PRIVATE universities (max 3)
