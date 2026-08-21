/**
 * Creates complete Path A and Path B test cases for all three templates.
 *
 * Assumes Account/Contact from setup_demo_data.apex already exist.
 * Run with: sf apex run --file scripts/apex/setup_path_ab_test_cases.apex --target-org allergan-moxie
 *
 * Creates:
 *   Path A cases (no email thread) x3  - one per template
 *   Path B cases (email thread)    x3  - one per template
 */

Account acct = [SELECT Id FROM Account WHERE Name = 'Sunset Aesthetics Medical Group' LIMIT 1];
Contact cont = [SELECT Id FROM Contact WHERE Email = 'sarah.chen@sunsetaesthetics.example.com' LIMIT 1];

// ══════════════════════════════════════════════════════════════
// PATH A CASES - no emails, first contact
// ══════════════════════════════════════════════════════════════

// PATH A-1 - Template A (Medical Director Change)
Case pathA1 = new Case(
    Subject     = 'TEST Path A - Medical Director Change - Dr. Patel replacing Dr. Kim',
    Status      = 'New',
    Type        = 'Account Support',
    Reason      = 'Credentialing',
    AccountId   = acct.Id,
    ContactId   = cont.Id,
    Priority    = 'Medium',
    Origin      = 'Email',
    Description = 'Our current Medical Director Dr. Kim is relocating to New York at the end of the quarter. We would like to transition the Medical Director role to Dr. Anita Patel who has been with our practice for 6 months and holds an active California medical license (License #CA-891234). Please advise on the process and any forms we need to complete.'
);

// PATH A-2 - Template B (New Practice Enrollment)
Case pathA2 = new Case(
    Subject     = 'TEST Path A - New Practice Enrollment - Pacific Coast Aesthetics',
    Status      = 'New',
    Type        = 'Account Support',
    Reason      = 'Credentialing',
    AccountId   = acct.Id,
    ContactId   = cont.Id,
    Priority    = 'Medium',
    Origin      = 'Email',
    Description = 'We are a new aesthetic medical practice opening at 789 Pacific Coast Highway, Malibu, CA 90265. Dr. Elena Vasquez will serve as Medical Director. We would like to enroll with Allergan Moxie to access the full product portfolio including BOTOX Cosmetic and Juvederm. Dr. Vasquez holds active licenses in CA and NV. The practice carries $2M/$4M malpractice coverage. We expect approximately 150 patients per month once enrolled.'
);

// PATH A-3 - Template C (Not Eligible)
Case pathA3 = new Case(
    Subject     = 'TEST Path A - Product Access Review - Eligibility Determination Needed',
    Status      = 'New',
    Type        = 'Account Support',
    Reason      = 'Credentialing',
    AccountId   = acct.Id,
    ContactId   = cont.Id,
    Priority    = 'Medium',
    Origin      = 'Email',
    Description = 'Account has submitted a request to access Allergan Moxie injectable products. After reviewing the application, our credentialing team has determined that this account does not currently meet the minimum eligibility requirements. The primary injector does not hold an active California medical license, and the practice does not carry the required malpractice insurance of $1M per occurrence / $3M aggregate. We need to communicate the not-eligible determination and explain the 30-day dispute process.'
);

insert new List<Case>{ pathA1, pathA2, pathA3 };

// ══════════════════════════════════════════════════════════════
// PATH B CASES - existing email thread
// ══════════════════════════════════════════════════════════════

// PATH B-1 - Template A: Medical Director Change with thread
Case pathB1 = new Case(
    Subject     = 'TEST Path B - Medical Director Change - Forms Sent, Awaiting Signatures',
    Status      = 'In Progress',
    Type        = 'Account Support',
    Reason      = 'Credentialing',
    AccountId   = acct.Id,
    ContactId   = cont.Id,
    Priority    = 'Medium',
    Origin      = 'Email',
    Description = 'Follow-up on Medical Director change from Dr. Kim to Dr. Patel. Form AM-CMD-001 was sent 5 days ago. Customer is asking about digital signature and deadline due to Dr. Kim travelling.'
);

// PATH B-2 - Template B: New Practice Enrollment with thread
Case pathB2 = new Case(
    Subject     = 'TEST Path B - New Practice Enrollment - Missing Insurance Certificate',
    Status      = 'In Progress',
    Type        = 'Account Support',
    Reason      = 'Credentialing',
    AccountId   = acct.Id,
    ContactId   = cont.Id,
    Priority    = 'Medium',
    Origin      = 'Email',
    Description = 'Pacific Coast Aesthetics submitted enrollment forms but did not include the malpractice insurance declaration page. Forms AM-PE-002 and AM-PC-005 received. DEA certificate received. Business license received. Only the insurance certificate is outstanding.'
);

// PATH B-3 - Template C: Not Eligible with thread (customer is disputing)
Case pathB3 = new Case(
    Subject     = 'TEST Path B - Product Access Review - Customer Disputing Eligibility Decision',
    Status      = 'In Progress',
    Type        = 'Account Support',
    Reason      = 'Credentialing',
    AccountId   = acct.Id,
    ContactId   = cont.Id,
    Priority    = 'High',
    Origin      = 'Email',
    Description = 'Account was notified they do not meet eligibility requirements (no active CA license, insufficient insurance). Customer is disputing - they claim the CA license was renewed last month and they have upgraded their insurance coverage. They have submitted supporting documents for formal review within the 30-day dispute window.'
);

insert new List<Case>{ pathB1, pathB2, pathB3 };

// ══════════════════════════════════════════════════════════════
// EMAIL THREADS for Path B cases
// ══════════════════════════════════════════════════════════════

// ── Path B-1 thread: Medical Director Change ──────────────────

// Email 1 - Customer's initial request (Day -8)
insert new EmailMessage(
    ParentId    = pathB1.Id,
    Subject     = 'Medical Director Change - Dr. Patel replacing Dr. Kim',
    TextBody    = 'Hello,\n\nI need to update the Medical Director on our Allergan Moxie account. Our current director, Dr. Kim, is relocating to New York. Her last day is in 6 weeks. We would like to appoint Dr. Anita Patel as the new Medical Director.\n\nCould you please send us the forms we need to complete?\n\nThank you,\nSarah Chen\nSunset Aesthetics Medical Group',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress   = 'providerservices@allergancmoxie.example.com',
    Incoming    = true,
    MessageDate = DateTime.now().addDays(-8),
    Status      = '0'
);

// Email 2 - CSR first response (Day -7)
insert new EmailMessage(
    ParentId    = pathB1.Id,
    Subject     = 'Re: Medical Director Change - Dr. Patel replacing Dr. Kim',
    TextBody    = 'Dear Sarah,\n\nThank you for contacting Allergan Moxie Provider Services. We have received your request to update the Medical Director on your account.\n\nTo process the Medical Director change, please submit the following documents:\n1. Completed Change of Medical Director Form (Form AM-CMD-001), signed by both Dr. Kim and Dr. Patel.\n2. A copy of Dr. Patel\'s current California medical license.\n3. An updated W-9 form if Dr. Patel is associated with a different tax entity.\n\nI have attached Form AM-CMD-001 to this email. Once all documents are received, please allow 5-7 business days for processing.\n\nWarm regards,\nDerek S.\nProvider Services, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress   = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming    = false,
    MessageDate = DateTime.now().addDays(-7),
    Status      = '3'
);

// Email 3 - Customer follow-up (Day -1): Dr. Kim is travelling, asks about digital signature and deadline
insert new EmailMessage(
    ParentId    = pathB1.Id,
    Subject     = 'Re: Medical Director Change - Dr. Patel replacing Dr. Kim',
    TextBody    = 'Hi Derek,\n\nThank you for sending the form. I have forwarded it to both Dr. Kim and Dr. Patel but Dr. Kim is currently travelling internationally and we are not sure exactly when she will be back. She may be able to sign digitally from abroad.\n\nTwo quick questions:\n1. Is digital or electronic signature acceptable for Form AM-CMD-001?\n2. Is there a hard deadline we are working towards given Dr. Kim\'s last day is in about 5 weeks?\n\nWe want to make sure we do not create a gap in our credentialing.\n\nThanks,\nSarah',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress   = 'providerservices@allergancmoxie.example.com',
    Incoming    = true,
    MessageDate = DateTime.now().addDays(-1),
    Status      = '0'
);

// ── Path B-2 thread: New Practice Enrollment ──────────────────

// Email 1 - Customer submits forms (Day -10)
insert new EmailMessage(
    ParentId    = pathB2.Id,
    Subject     = 'New Provider Enrollment - Pacific Coast Aesthetics',
    TextBody    = 'Hello,\n\nPlease find attached our completed enrollment forms for Pacific Coast Aesthetics at 789 Pacific Coast Highway, Malibu CA 90265. Attached: Form AM-PE-002 (signed by Dr. Elena Vasquez), Form AM-PC-005, DEA Certificate, and Business License.\n\nPlease let us know if anything else is required.\n\nThank you,\nSarah Chen',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress   = 'providerservices@allergancmoxie.example.com',
    Incoming    = true,
    MessageDate = DateTime.now().addDays(-10),
    Status      = '0'
);

// Email 2 - CSR acknowledges and flags missing document (Day -8)
insert new EmailMessage(
    ParentId    = pathB2.Id,
    Subject     = 'Re: New Provider Enrollment - Pacific Coast Aesthetics',
    TextBody    = 'Dear Sarah,\n\nThank you for submitting your enrollment documents for Pacific Coast Aesthetics. We have received and reviewed the following:\n\n✓ Form AM-PE-002 (signed)\n✓ Form AM-PC-005 (signed)\n✓ DEA Certificate\n✓ Business License\n\nWe are still missing one required document:\n- Proof of malpractice/liability insurance - minimum $1,000,000 per occurrence / $3,000,000 aggregate (insurance declaration page required)\n\nOnce we receive this document, we can proceed with the credentialing review. Processing takes 10-14 business days from receipt of a complete application.\n\nKind regards,\nAmanda P.\nProvider Enrollment Team, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress   = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming    = false,
    MessageDate = DateTime.now().addDays(-8),
    Status      = '3'
);

// Email 3 - Customer asks a question about coverage amount (Day -1)
insert new EmailMessage(
    ParentId    = pathB2.Id,
    Subject     = 'Re: New Provider Enrollment - Pacific Coast Aesthetics',
    TextBody    = 'Hi Amanda,\n\nThank you for the checklist. We do have malpractice coverage but our current policy is $1M per occurrence / $2M aggregate. I believe the requirement is $1M / $3M. We are in the process of upgrading our coverage.\n\nTwo questions:\n1. Can we proceed with the application while the upgraded policy is being issued? The insurer says it will take about 2 weeks.\n2. If we cannot proceed until the new policy is in place, does the 10-14 day processing clock start from when you receive the insurance certificate, or from our original submission date?\n\nThank you,\nSarah',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress   = 'providerservices@allergancmoxie.example.com',
    Incoming    = true,
    MessageDate = DateTime.now().addDays(-1),
    Status      = '0'
);

// ── Path B-3 thread: Not Eligible - Customer disputing ────────

// Email 1 - CSR sent not-eligible determination (Day -12)
insert new EmailMessage(
    ParentId    = pathB3.Id,
    Subject     = 'Product Access Review - Eligibility Determination',
    TextBody    = 'Dear Sarah,\n\nThank you for contacting Allergan Moxie Provider Services regarding Case #[auto-assigned].\n\nAfter reviewing your account and the details submitted for Sunset Aesthetics Medical Group, we regret to inform you that based on our current eligibility criteria, your practice does not meet the requirements for the requested product or program at this time.\n\nThis determination was made based on:\n- The primary injector does not hold an active California medical license.\n- The practice does not carry the required malpractice insurance of $1M per occurrence / $3M aggregate.\n\nPlease review Form AM-EL-010 for details on eligibility requirements. If you believe this determination was made in error, please reply with supporting documentation within 30 days for a formal review.\n\nRegards,\nCarla N.\nProvider Services Representative, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress   = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming    = false,
    MessageDate = DateTime.now().addDays(-12),
    Status      = '3'
);

// Email 2 - Customer disputes with evidence (Day -5)
insert new EmailMessage(
    ParentId    = pathB3.Id,
    Subject     = 'Re: Product Access Review - Eligibility Determination',
    TextBody    = 'Dear Carla,\n\nThank you for your response. We believe the eligibility determination may be based on outdated information. We would like to formally dispute this under the 30-day review process.\n\nAttached please find:\n1. Dr. Patel\'s renewed California medical license - issued 3 weeks ago (License #CA-891234, valid through 2027).\n2. Updated malpractice insurance declaration page - effective last week, coverage is now $2M per occurrence / $4M aggregate, which exceeds the minimum requirement.\n\nWe respectfully request a formal review of our eligibility status in light of these updated documents.\n\nThank you,\nSarah Chen\nSunset Aesthetics Medical Group',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress   = 'providerservices@allergancmoxie.example.com',
    Incoming    = true,
    MessageDate = DateTime.now().addDays(-5),
    Status      = '0'
);

// Email 3 - CSR acknowledged receipt of dispute (Day -4)
insert new EmailMessage(
    ParentId    = pathB3.Id,
    Subject     = 'Re: Product Access Review - Eligibility Determination',
    TextBody    = 'Dear Sarah,\n\nThank you for submitting your dispute and the supporting documentation. We have received the following:\n\n- Dr. Patel\'s renewed California medical license\n- Updated malpractice insurance declaration page\n\nYour dispute has been escalated to our credentialing review team. You can expect a decision within 5-7 business days. We will contact you at this email address once the review is complete.\n\nWarm regards,\nCarla N.\nProvider Services Representative, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress   = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming    = false,
    MessageDate = DateTime.now().addDays(-4),
    Status      = '3'
);

// Email 4 - Customer follows up asking for status (today)
insert new EmailMessage(
    ParentId    = pathB3.Id,
    Subject     = 'Re: Product Access Review - Eligibility Determination',
    TextBody    = 'Hi Carla,\n\nJust following up on our dispute submission from last week. It has now been 5 business days and we have not yet received a decision. Could you please provide an update on where the review stands?\n\nWe are eager to move forward and begin ordering products as soon as the eligibility issue is resolved.\n\nThank you,\nSarah',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress   = 'providerservices@allergancmoxie.example.com',
    Incoming    = true,
    MessageDate = DateTime.now(),
    Status      = '0'
);

// ══════════════════════════════════════════════════════════════
System.debug('');
System.debug('=== PATH A/B TEST CASES CREATED SUCCESSFULLY ===');
System.debug('');
System.debug('PATH A (no thread - first contact):');
System.debug('  A-1 Template A: ' + pathA1.Id + ' - ' + pathA1.Subject);
System.debug('  A-2 Template B: ' + pathA2.Id + ' - ' + pathA2.Subject);
System.debug('  A-3 Template C: ' + pathA3.Id + ' - ' + pathA3.Subject);
System.debug('');
System.debug('PATH B (email thread - follow-up reply):');
System.debug('  B-1 Template A: ' + pathB1.Id + ' - ' + pathB1.Subject + ' (3 emails)');
System.debug('  B-2 Template B: ' + pathB2.Id + ' - ' + pathB2.Subject + ' (3 emails)');
System.debug('  B-3 Template C: ' + pathB3.Id + ' - ' + pathB3.Subject + ' (4 emails)');
System.debug('');
System.debug('Open each case, click Email tab, Draft with AI, Custom CSR Response, Generate.');
