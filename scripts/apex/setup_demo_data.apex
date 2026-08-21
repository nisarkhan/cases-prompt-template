/**
 * Demo data setup script for Allergan Moxie Agentforce Email Draft demo.
 *
 * Run with:  sf apex run --file scripts/apex/setup_demo_data.apex --target-org <alias>
 *
 * Creates:
 *   - 1 Account (Sunset Aesthetics Medical Group)
 *   - 1 Contact (Dr. Sarah Chen)
 *   - 3 CLOSED historical cases (same Type/Reason as the demo cases)
 *     with outbound EmailMessages attached - these feed the Prompt Flow
 *   - 2 OPEN demo cases ready to show:
 *       Demo Case A: New credentialing case (no emails yet) - Path A demo
 *       Demo Case B: Existing case with reply thread - Path B demo
 */

// ── 1. Account ────────────────────────────────────────────────────────────
Account acct = new Account(
    Name = 'Sunset Aesthetics Medical Group',
    Phone = '(310) 555-0182',
    BillingCity = 'Los Angeles',
    BillingState = 'CA'
);
insert acct;

// ── 2. Contact ────────────────────────────────────────────────────────────
Contact con = new Contact(
    FirstName = 'Sarah',
    LastName = 'Chen',
    Email = 'sarah.chen@sunsetaesthetics.example.com',
    Title = 'Practice Manager',
    AccountId = acct.Id
);
insert con;

// ── 3. Closed historical cases (grounding data for the Prompt Flow) ───────
List<Case> historicalCases = new List<Case>{
    new Case(
        Subject = 'Medical Director Change - Dr. James Park stepping down',
        Type = 'Account Support',
        Reason = 'Credentialing',
        Status = 'Closed',
        AccountId = acct.Id,
        ContactId = con.Id,
        Description = 'Practice requesting change of medical director from Dr. Park to Dr. Kim.'
    ),
    new Case(
        Subject = 'Medical Director Change - Incoming Dr. Liu not yet licensed',
        Type = 'Account Support',
        Reason = 'Credentialing',
        Status = 'Closed',
        AccountId = acct.Id,
        ContactId = con.Id,
        Description = 'Incoming MD does not yet have active CA license. Practice needs guidance.'
    ),
    new Case(
        Subject = 'Medical Director Update - Name correction on file',
        Type = 'Account Support',
        Reason = 'Credentialing',
        Status = 'Closed',
        AccountId = acct.Id,
        ContactId = con.Id,
        Description = 'Minor correction to Medical Director name spelling on credentialing record.'
    )
};
insert historicalCases;

// ── 4. Outbound emails on the closed cases (what the Prompt Flow reads) ───
List<EmailMessage> historicalEmails = new List<EmailMessage>{
    new EmailMessage(
        ParentId = historicalCases[0].Id,
        Subject = 'Re: Medical Director Change - Dr. James Park stepping down',
        TextBody = 'Dear Sarah,\n\nThank you for contacting Allergan Moxie Provider Services. We have received your request to update the Medical Director on file for Sunset Aesthetics Medical Group.\n\nTo process this change, please submit the following: (1) Completed Form AM-CMD-001 signed by both outgoing and incoming Medical Directors, (2) A copy of the incoming Medical Director\'s current medical license, (3) An updated W-9 if the tax entity has changed.\n\nProcessing takes 5-7 business days once all documents are received.\n\nWarm regards,\nJessica M.\nProvider Services',
        FromAddress = 'providerservices@allergancmoxie.example.com',
        ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
        Incoming = false,
        MessageDate = DateTime.now().addDays(-45),
        Status = '3'
    ),
    new EmailMessage(
        ParentId = historicalCases[1].Id,
        Subject = 'Re: Medical Director Change - Incoming Dr. Liu not yet licensed',
        TextBody = 'Dear Sarah,\n\nThank you for reaching out. We understand you are planning a Medical Director transition and that Dr. Liu\'s California license is pending.\n\nUnfortunately we are unable to process the Medical Director change until the incoming director holds an active, valid license in the state of practice. Once Dr. Liu\'s license is issued, please submit Form AM-CMD-001 along with a copy of the license and we will prioritize your case.\n\nIn the meantime, Dr. Park\'s credentials remain active on your account.\n\nPlease do not hesitate to reach out if you have any questions.\n\nKind regards,\nMarcus T.\nProvider Services',
        FromAddress = 'providerservices@allergancmoxie.example.com',
        ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
        Incoming = false,
        MessageDate = DateTime.now().addDays(-30),
        Status = '3'
    ),
    new EmailMessage(
        ParentId = historicalCases[2].Id,
        Subject = 'Re: Medical Director Update - Name correction on file',
        TextBody = 'Dear Sarah,\n\nThank you for flagging the name discrepancy on your account. We have updated the Medical Director name on your credentialing record to reflect the correct legal name.\n\nNo additional forms are required for a minor name correction. Your account remains in good standing and no other changes have been made.\n\nPlease allow 24-48 hours for the update to reflect across all systems. Let us know if you notice any further discrepancies.\n\nWarm regards,\nJennifer R.\nProvider Services',
        FromAddress = 'providerservices@allergancmoxie.example.com',
        ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
        Incoming = false,
        MessageDate = DateTime.now().addDays(-15),
        Status = '3'
    )
};
insert historicalEmails;

// ── 5. Demo Case A - NEW case, no emails yet (Path A demo) ────────────────
Case demoCaseA = new Case(
    Subject = 'Medical Director Change Request - New Director Dr. Patel',
    Type = 'Account Support',
    Reason = 'Credentialing',
    Status = 'New',
    AccountId = acct.Id,
    ContactId = con.Id,
    Description = 'Our current Medical Director Dr. Kim is relocating to New York. We would like to transition the role to Dr. Anita Patel who joined our practice last month. Dr. Patel holds an active California medical license. Please advise on next steps.'
);
insert demoCaseA;

// ── 6. Demo Case B - EXISTING case with reply thread (Path B demo) ────────
Case demoCaseB = new Case(
    Subject = 'Medical Director Change - Awaiting Form AM-CMD-001',
    Type = 'Account Support',
    Reason = 'Credentialing',
    Status = 'In Progress',
    AccountId = acct.Id,
    ContactId = con.Id,
    Description = 'Follow-up on pending Medical Director change. Forms were requested 7 days ago.'
);
insert demoCaseB;

// Inbound email from customer (they asked for help)
EmailMessage inbound1 = new EmailMessage(
    ParentId = demoCaseB.Id,
    Subject = 'Medical Director Change - Awaiting Form AM-CMD-001',
    TextBody = 'Hi,\n\nI submitted a request last week to change our Medical Director from Dr. Kim to Dr. Patel. I have not yet received the forms that need to be signed. Could you please resend Form AM-CMD-001 and let us know what else is needed? We are hoping to complete this before the end of the month.\n\nThank you,\nSarah Chen\nSunset Aesthetics',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress = 'providerservices@allergancmoxie.example.com',
    Incoming = true,
    MessageDate = DateTime.now().addDays(-7),
    Status = '0'
);
insert inbound1;

// Outbound reply from CSR (sent 6 days ago)
EmailMessage outbound1 = new EmailMessage(
    ParentId = demoCaseB.Id,
    Subject = 'Re: Medical Director Change - Awaiting Form AM-CMD-001',
    TextBody = 'Dear Sarah,\n\nThank you for following up. I have attached Form AM-CMD-001 to this email for your convenience. Please have both Dr. Kim and Dr. Patel sign and return at your earliest convenience.\n\nAs a reminder, you will also need to provide a copy of Dr. Patel\'s current California medical license and an updated W-9 if applicable.\n\nDo not hesitate to reach out if you need anything further.\n\nWarm regards,\nDerek S.\nProvider Services, Allergan Moxie',
    FromAddress = 'providerservices@allergancmoxie.example.com',
    ToAddress = 'sarah.chen@sunsetaesthetics.example.com',
    Incoming = false,
    MessageDate = DateTime.now().addDays(-6),
    Status = '3'
);
insert outbound1;

// Second inbound - customer following up again today, forms still not returned
EmailMessage inbound2 = new EmailMessage(
    ParentId = demoCaseB.Id,
    Subject = 'Re: Medical Director Change - Awaiting Form AM-CMD-001',
    TextBody = 'Hi Derek,\n\nI received the form, thank you. I have sent it to Dr. Kim and Dr. Patel for signature but Dr. Kim is currently traveling and we are not sure when she will return. Is there a deadline we need to be aware of? Also, is there a way to do a digital signature?\n\nThanks,\nSarah',
    FromAddress = 'sarah.chen@sunsetaesthetics.example.com',
    ToAddress = 'providerservices@allergancmoxie.example.com',
    Incoming = true,
    MessageDate = DateTime.now().addDays(-1),
    Status = '0'
);
insert inbound2;

System.debug('=== DEMO DATA CREATED SUCCESSFULLY ===');
System.debug('Account ID:    ' + acct.Id);
System.debug('Contact ID:    ' + con.Id);
System.debug('Demo Case A (Path A - New, no emails): ' + demoCaseA.Id + ' - ' + demoCaseA.Subject);
System.debug('Demo Case B (Path B - Existing thread): ' + demoCaseB.Id + ' - ' + demoCaseB.Subject);
System.debug('Historical Cases: ' + historicalCases[0].Id + ', ' + historicalCases[1].Id + ', ' + historicalCases[2].Id);
System.debug('');
System.debug('NEXT STEPS:');
System.debug('1. Open Demo Case A in your org, go to the Email tab, click Draft with AI');
System.debug('2. Select "Custom CSR Response" prompt template - should recommend Template A');
System.debug('3. Open Demo Case B, go to the Email tab, click Draft with AI');
System.debug('4. Should produce a follow-up reply addressing Dr. Kim\'s travel and the digital signature question');
