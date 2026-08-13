/**
 * Demo data setup — Patient Treatment Journey cases (Part C)
 *
 * Run with:
 *   sf apex run --file scripts/apex/setup_patient_journey_cases.apex --target-org <alias>
 *
 * Creates:
 *   - 3 CLOSED historical cases (Patient Support / Treatment) with outbound emails
 *     for Prompt Flow tone grounding
 *   - Case C-1: Treatment Planning — new case, no thread (Path A, First Contact)
 *   - Case C-2: Treatment Planning — existing thread, provider has follow-up questions
 *   - Case C-3: Adverse Event — new case, no thread (Path A, First Contact)
 *   - Case C-4: Adverse Event — existing thread, provider asking about timeline
 *
 * Reuses the existing Sunset Aesthetics Medical Group account and Sarah Chen contact
 * if they already exist — otherwise creates them.
 */

// ── 1. Find or create Account ──────────────────────────────────────────────
List<Account> existingAccts = [SELECT Id FROM Account WHERE Name = 'Sunset Aesthetics Medical Group' LIMIT 1];
Account acct;
if (!existingAccts.isEmpty()) {
    acct = existingAccts[0];
    System.debug('Reusing existing Account: ' + acct.Id);
} else {
    acct = new Account(
        Name = 'Sunset Aesthetics Medical Group',
        Phone = '(310) 555-0182',
        BillingCity = 'Los Angeles',
        BillingState = 'CA'
    );
    insert acct;
    System.debug('Created Account: ' + acct.Id);
}

// ── 2. Find or create Contact ──────────────────────────────────────────────
List<Contact> existingCons = [SELECT Id FROM Contact WHERE Email = 'sarah.chen@sunsetaesthetics.example.com' LIMIT 1];
Contact con;
if (!existingCons.isEmpty()) {
    con = existingCons[0];
    System.debug('Reusing existing Contact: ' + con.Id);
} else {
    con = new Contact(
        FirstName = 'Sarah',
        LastName = 'Chen',
        Email = 'sarah.chen@sunsetaesthetics.example.com',
        Title = 'Practice Manager',
        AccountId = acct.Id
    );
    insert con;
    System.debug('Created Contact: ' + con.Id);
}

// ── 3. Closed historical cases for grounding ──────────────────────────────
List<Case> historicalCases = new List<Case>{
    new Case(
        Subject = 'Patient Treatment Planning - Juvederm protocol inquiry',
        Type = 'Patient Support',
        Reason = 'Treatment',
        Status = 'Closed',
        AccountId = acct.Id,
        ContactId = con.Id,
        Description = 'Provider asked about product availability and consent form requirements before a filler treatment session.'
    ),
    new Case(
        Subject = 'Patient Treatment Planning - Botox dosage confirmation',
        Type = 'Patient Support',
        Reason = 'Treatment',
        Status = 'Closed',
        AccountId = acct.Id,
        ContactId = con.Id,
        Description = 'Provider requested dosage guidance for a first-time Botox patient before scheduled appointment.'
    ),
    new Case(
        Subject = 'Adverse Event Report - Mild bruising post-filler',
        Type = 'Patient Support',
        Reason = 'Treatment',
        Status = 'Closed',
        AccountId = acct.Id,
        ContactId = con.Id,
        Description = 'Provider reported mild bruising at injection site. No serious adverse outcome. AE form submitted and reviewed.'
    )
};
insert historicalCases;

// Outbound historical emails for Prompt Flow tone grounding
List<EmailMessage> historicalEmails = new List<EmailMessage>{
    new EmailMessage(
        ParentId = historicalCases[0].Id,
        Subject = 'Re: Patient Treatment Planning - Juvederm protocol inquiry',
        TextBody = 'Dear Sarah,\n\nThank you for reaching out ahead of your upcoming treatment session. We are pleased to confirm the requested Juvederm products are available and your account is in good standing.\n\nPlease ensure the patient has signed Form AM-PC-005 prior to treatment and that you record the product lot number and expiry in the patient file as required by Form AM-TR-001.\n\nIf you need any additional product units please let us know at least 48 hours before the appointment.\n\nWarm regards,\nJessica M.\nProvider Services, Allergan Moxie',
        FromAddress = 'providerservices@allergancmoxie.example.com',
        ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
        Incoming = false,
        MessageDate = DateTime.now().addDays(-60),
        Status = '3'
    ),
    new EmailMessage(
        ParentId = historicalCases[1].Id,
        Subject = 'Re: Patient Treatment Planning - Botox dosage confirmation',
        TextBody = 'Dear Sarah,\n\nThank you for contacting us. For first-time Botox patients we recommend reviewing the Allergan Moxie dosing guidelines available in your provider portal. Our clinical team is also available for a pre-treatment consultation call if you would like guidance specific to the patient profile.\n\nPlease confirm Form AM-PC-005 has been completed and that lot number and expiry documentation will be recorded at time of administration per Form AM-TR-001.\n\nLet us know if you have any further questions before the appointment.\n\nKind regards,\nMarcus T.\nProvider Services, Allergan Moxie',
        FromAddress = 'providerservices@allergancmoxie.example.com',
        ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
        Incoming = false,
        MessageDate = DateTime.now().addDays(-40),
        Status = '3'
    ),
    new EmailMessage(
        ParentId = historicalCases[2].Id,
        Subject = 'Re: Adverse Event Report - Mild bruising post-filler',
        TextBody = 'Dear Sarah,\n\nThank you for promptly reporting this event. We have received your completed Form AM-AE-003 and have logged this as a mild, non-serious adverse event.\n\nOur clinical team has reviewed the details and no further action is required at this time. The event has been recorded in accordance with our safety reporting obligations under the Provider Agreement.\n\nPlease retain the patient\'s signed consent form (Form AM-PC-005) in their file. If the patient experiences any further symptoms please contact us immediately.\n\nWarm regards,\nJennifer R.\nProvider Services, Allergan Moxie',
        FromAddress = 'providerservices@allergancmoxie.example.com',
        ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
        Incoming = false,
        MessageDate = DateTime.now().addDays(-20),
        Status = '3'
    )
};
insert historicalEmails;

// ── 4. Case C-1 — Treatment Planning, no thread (First Contact demo) ───────
Case caseC1 = new Case(
    Subject = 'Patient Treatment Planning - Sculptra session for 3 patients',
    Type = 'Patient Support',
    Reason = 'Treatment',
    Status = 'New',
    AccountId = acct.Id,
    ContactId = con.Id,
    Description = 'We have three patients scheduled for Sculptra Aesthetic treatments next Thursday. This is our first time using Sculptra at our practice. Dr. Patel will be the treating provider. We want to confirm product availability, check what forms the patients need to sign, and understand what documentation we need to keep on file. Patient ages are 42, 55, and 61. No known contraindications.'
);
insert caseC1;

// ── 5. Case C-2 — Treatment Planning, existing thread (Reply demo) ─────────
Case caseC2 = new Case(
    Subject = 'Patient Treatment Planning - Pre-treatment checklist questions',
    Type = 'Patient Support',
    Reason = 'Treatment',
    Status = 'In Progress',
    AccountId = acct.Id,
    ContactId = con.Id,
    Description = 'Provider has questions about the pre-treatment documentation requirements following our initial response.'
);
insert caseC2;

// Thread: inbound from provider
EmailMessage c2Inbound1 = new EmailMessage(
    ParentId = caseC2.Id,
    Subject = 'Patient Treatment Planning - Pre-treatment checklist questions',
    TextBody = 'Hello,\n\nWe have a Botox treatment session coming up next week for two new patients. Can you please confirm what forms they need to sign and whether we need to submit anything to you before the appointment?\n\nThank you,\nSarah Chen\nSunset Aesthetics Medical Group',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress = 'providerservices@allergancmoxie.example.com',
    Incoming = true,
    MessageDate = DateTime.now().addDays(-5),
    Status = '0'
);
insert c2Inbound1;

// CSR first reply with full checklist
EmailMessage c2Outbound1 = new EmailMessage(
    ParentId = caseC2.Id,
    Subject = 'Re: Patient Treatment Planning - Pre-treatment checklist questions',
    TextBody = 'Dear Sarah,\n\nThank you for reaching out ahead of your upcoming Botox session. Your account is in good standing and the products are available.\n\nPlease ensure the following before the appointment:\n1. Each patient completes and signs Form AM-PC-005 (Patient Consent Form) prior to treatment.\n2. Record the product lot number and expiry date in each patient file at time of administration — this is required under Form AM-TR-001.\n3. Any adverse events must be reported within 24 hours using Form AM-AE-003.\n\nYou do not need to submit anything to us in advance — just retain the signed consent forms in each patient file.\n\nPlease let us know if you have any questions.\n\nWarm regards,\nDerek S.\nProvider Services, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming = false,
    MessageDate = DateTime.now().addDays(-4),
    Status = '3'
);
insert c2Outbound1;

// Provider follow-up with specific questions
EmailMessage c2Inbound2 = new EmailMessage(
    ParentId = caseC2.Id,
    Subject = 'Re: Patient Treatment Planning - Pre-treatment checklist questions',
    TextBody = 'Hi Derek,\n\nThank you for the information. A couple of follow-up questions:\n1. One of our patients is on blood thinners. Does that affect anything on our end from a documentation standpoint, or is that purely a clinical decision for Dr. Patel?\n2. How long do we need to retain the signed consent forms — is there a minimum retention period?\n\nThanks,\nSarah',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress = 'providerservices@allergancmoxie.example.com',
    Incoming = true,
    MessageDate = DateTime.now().addDays(-1),
    Status = '0'
);
insert c2Inbound2;

// ── 6. Case C-3 — Adverse Event, no thread (First Contact demo) ────────────
Case caseC3 = new Case(
    Subject = 'Adverse Event Report - Post-treatment swelling and redness',
    Type = 'Patient Support',
    Reason = 'Treatment',
    Status = 'New',
    AccountId = acct.Id,
    ContactId = con.Id,
    Description = 'Patient presented with significant swelling and redness at the injection site approximately 6 hours after a Juvederm filler treatment performed yesterday by Dr. Patel. The reaction is more pronounced than typical post-treatment swelling. Patient is a 48-year-old female with no prior history of filler treatments. Product lot number: JUV-2026-084512, expiry: 2027-03. We have contacted the patient and she is monitoring at home. No emergency intervention required at this time. Please advise on next steps and reporting requirements.'
);
insert caseC3;

// ── 7. Case C-4 — Adverse Event, existing thread (Reply demo) ─────────────
Case caseC4 = new Case(
    Subject = 'Adverse Event Follow-Up - Form AM-AE-003 submission questions',
    Type = 'Patient Support',
    Reason = 'Treatment',
    Status = 'In Progress',
    AccountId = acct.Id,
    ContactId = con.Id,
    Description = 'Provider has submitted an adverse event report and has questions about what happens next.'
);
insert caseC4;

// First inbound — provider reporting the event
EmailMessage c4Inbound1 = new EmailMessage(
    ParentId = caseC4.Id,
    Subject = 'Adverse Event - Patient reaction after Botox treatment',
    TextBody = 'Hello,\n\nI need to report an adverse event. One of our patients experienced mild eyelid drooping (ptosis) approximately 3 days after a Botox treatment performed last week. The patient is not in distress and the symptom appears to be resolving. Dr. Patel treated her. Product lot: BTX-2026-091233, expiry 2027-06.\n\nWhat do we need to do?\n\nSarah Chen\nSunset Aesthetics Medical Group',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress = 'providerservices@allergancmoxie.example.com',
    Incoming = true,
    MessageDate = DateTime.now().addDays(-3),
    Status = '0'
);
insert c4Inbound1;

// CSR reply with full AE reporting requirements
EmailMessage c4Outbound1 = new EmailMessage(
    ParentId = caseC4.Id,
    Subject = 'Re: Adverse Event - Patient reaction after Botox treatment',
    TextBody = 'Dear Sarah,\n\nThank you for promptly reporting this. We take all adverse events seriously.\n\nPlease complete the following as soon as possible:\n1. Submit Form AM-AE-003 (Adverse Event Reporting Form) — this must be submitted within 72 hours of identification.\n2. Include the product lot number BTX-2026-091233 and expiry 2027-06 on the form.\n3. Provide a brief clinical description: onset timing, severity, any intervention provided.\n4. Retain the patient\'s signed Form AM-PC-005 in her file — do not submit it but keep it available for review.\n\nPlease note that late reporting may affect your account standing under Section 4.2 of the Provider Agreement.\n\nOur clinical team will follow up within one business day of receiving the completed form.\n\nWarm regards,\nDerek S.\nProvider Services, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming = false,
    MessageDate = DateTime.now().addDays(-2),
    Status = '3'
);
insert c4Outbound1;

// Provider follow-up questions
EmailMessage c4Inbound2 = new EmailMessage(
    ParentId = caseC4.Id,
    Subject = 'Re: Adverse Event - Patient reaction after Botox treatment',
    TextBody = 'Hi Derek,\n\nThank you. We submitted Form AM-AE-003 this morning. A couple of questions:\n1. The 72-hour window — does that start from when the patient called us to report it, or from when the treatment was performed?\n2. The patient is asking if this will affect her ability to receive Botox treatments in the future. Is that something you can advise on, or should she consult her physician?\n\nThanks,\nSarah',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress = 'providerservices@allergancmoxie.example.com',
    Incoming = true,
    MessageDate = DateTime.now().addDays(-1),
    Status = '0'
);
insert c4Inbound2;

// ── Done ───────────────────────────────────────────────────────────────────
System.debug('=== PATIENT JOURNEY DEMO DATA CREATED ===');
System.debug('Account: ' + acct.Id);
System.debug('Contact: ' + con.Id);
System.debug('');
System.debug('CASE C-1 (Treatment Planning - First Contact): ' + caseC1.Id + ' | ' + caseC1.Subject);
System.debug('CASE C-2 (Treatment Planning - Reply):         ' + caseC2.Id + ' | ' + caseC2.Subject);
System.debug('CASE C-3 (Adverse Event - First Contact):      ' + caseC3.Id + ' | ' + caseC3.Subject);
System.debug('CASE C-4 (Adverse Event - Reply):              ' + caseC4.Id + ' | ' + caseC4.Subject);
System.debug('');
System.debug('HOW TO TEST:');
System.debug('C-1: Open case, click Draft with AI → CSR First Contact Email → expect Treatment Planning template');
System.debug('C-2: Open case, click Draft with AI → CSR Reply Email → expect focused reply on blood thinner docs + retention period, no checklist');
System.debug('C-3: Open case, click Draft with AI → CSR First Contact Email → expect Adverse Event template with full AE reporting requirements');
System.debug('C-4: Open case, click Draft with AI → CSR Reply Email → expect focused reply on 72hr window + future treatment question, no AE checklist');
