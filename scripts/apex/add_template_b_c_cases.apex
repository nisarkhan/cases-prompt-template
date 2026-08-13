// Creates two additional demo cases to trigger Template B and Template C
// Template B = New Practice Enrollment, Template C = Not Eligible for Products

Account acct = [SELECT Id FROM Account WHERE Name = 'Sunset Aesthetics Medical Group' LIMIT 1];
Contact cont = [SELECT Id FROM Contact WHERE Email = 'sarah.chen@sunsetaesthetics.example.com' LIMIT 1];

// ── CASE D — triggers Template B (New Practice Enrollment) ──────────────────
Case caseD = new Case(
    Subject       = 'New Practice Enrollment - Pacific Coast Aesthetics',
    Status        = 'New',
    Type          = 'Account Support',
    Reason        = 'Credentialing',
    AccountId     = acct.Id,
    ContactId     = cont.Id,
    Priority      = 'Medium',
    Origin        = 'Email',
    Description   = 'We are a new aesthetic medical practice opening at 789 Pacific Coast Highway, Malibu, CA 90265. Dr. Elena Vasquez will serve as Medical Director. We would like to enroll with Allergan Moxie to access the full product portfolio including BOTOX Cosmetic and Juvederm. We need to start the new provider enrollment process and understand which credentialing forms to submit. Dr. Vasquez holds active licenses in CA and NV and the practice carries $2M/$4M malpractice coverage. We expect to treat approximately 150 patients per month once enrolled.'
);

// ── CASE E — triggers Template C (Not Eligible for Products) ────────────────
Case caseE = new Case(
    Subject       = 'Product Access Review - Eligibility Determination Needed',
    Status        = 'New',
    Type          = 'Account Support',
    Reason        = 'Credentialing',
    AccountId     = acct.Id,
    ContactId     = cont.Id,
    Priority      = 'Medium',
    Origin        = 'Email',
    Description   = 'Account has submitted a request to access Allergan Moxie injectable products. After reviewing the application, our credentialing team has determined that this account does not currently meet the minimum eligibility requirements. The primary injector does not hold an active California medical license, and the practice does not carry the required malpractice insurance of $1M per occurrence / $3M aggregate. We need to communicate the not-eligible determination to the account and explain the 30-day dispute and re-evaluation process.'
);

insert new List<Case>{ caseD, caseE };

System.debug('Case D inserted: ' + caseD.Id + ' → expect Template B (New Practice Enrollment)');
System.debug('Case E inserted: ' + caseE.Id + ' → expect Template C (Not Eligible for Products)');
System.debug('Done — open these cases and click Draft with AI → Custom CSR Response.');
