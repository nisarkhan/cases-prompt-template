/**
 * Creates the three demo EmailTemplate records with When_To_Use__c populated.
 * These replace the hardcoded templates that were previously embedded in the Prompt Template.
 *
 * Prerequisites:
 *   1. Deploy the When_To_Use__c custom field first:
 *      sf project deploy start --source-dir force-app/main/default/objects --target-org allergan-moxie
 *   2. Then run this script:
 *      sf apex run --file scripts/apex/setup_email_templates.apex --target-org allergan-moxie
 *
 * In production: replace these 3 with the real ~1,600 Allergan Moxie templates,
 * each with When_To_Use__c filled in (one sentence describing the scenario).
 */

// ── Template A: Medical Director Change ──────────────────────────────────────

EmailTemplate tmplA = new EmailTemplate(
    Name            = 'AM - Medical Director Change Request',
    DeveloperName   = 'AM_Medical_Director_Change_Request',
    TemplateType    = 'text',
    FolderId        = UserInfo.getUserId(),
    IsActive        = true,
    Subject         = 'Your Medical Director Change Request - Case #{!Case.CaseNumber}',
    When_To_Use__c  = 'Use when a credentialed account is requesting to change or update the Medical Director on their account.',
    Body            = 'Dear {!Contact.FirstName},\n\nThank you for contacting the Allergan Moxie Provider Services team regarding your request for a Medical Director Change at {!Account.Name}.\n\nWe have received your request and are currently reviewing the required documentation for Case #{!Case.CaseNumber}.\n\nTo complete the Medical Director change, please ensure the following items are submitted:\n\n1. Completed Change of Medical Director Form (Form AM-CMD-001), signed by both the outgoing and incoming Medical Directors.\n2. A copy of the incoming Medical Director\'s current medical license (must be active and valid in the state of practice).\n3. An updated W-9 form if the new Medical Director is associated with a different tax entity.\n\nPlease return all completed documents to your dedicated Allergan Moxie representative or upload them directly to your account portal.\n\nOnce all required documentation is received and verified, please allow 5-7 business days for processing. You will receive a confirmation email when the change has been finalized.\n\nIf you have any questions or require assistance completing the forms, please do not hesitate to contact us by replying to this email or by calling our Provider Services line.\n\nThank you for your continued partnership with Allergan Moxie.\n\nWarm regards,\n{!User.FirstName} {!User.LastName}\nProvider Services Representative\nAllergan Moxie'
);

// ── Template B: New Practice Enrollment ──────────────────────────────────────

EmailTemplate tmplB = new EmailTemplate(
    Name            = 'AM - New Practice Enrollment',
    DeveloperName   = 'AM_New_Practice_Enrollment',
    TemplateType    = 'text',
    FolderId        = UserInfo.getUserId(),
    IsActive        = true,
    Subject         = 'Your Provider Enrollment Application - Case #{!Case.CaseNumber}',
    When_To_Use__c  = 'Use when a new practice or facility is requesting to enroll as an authorized Allergan Moxie provider for the first time.',
    Body            = 'Dear {!Contact.FirstName},\n\nThank you for your interest in enrolling {!Account.Name} as an authorized Allergan Moxie provider. We are pleased to assist you through the credentialing and enrollment process for Case #{!Case.CaseNumber}.\n\nTo proceed with your new practice enrollment, the following documentation is required:\n\n1. Completed Allergan Moxie Provider Enrollment Form (Form AM-PE-002), signed by the Medical Director.\n2. Current DEA Certificate and State Controlled Substance License (if applicable for your practice scope).\n3. Proof of malpractice/liability insurance - minimum $1,000,000 per occurrence / $3,000,000 aggregate.\n4. A copy of the facility\'s business license or certificate of occupancy.\n5. Completed and signed Patient Consent and Privacy Policy Acknowledgement (Form AM-PC-005).\n\nPlease note that incomplete applications may delay processing. All forms must be submitted together as a complete package.\n\nOnce we receive your complete submission, please allow 10-14 business days for review and credentialing verification. Our team will contact you if additional information is required.\n\nWe look forward to welcoming {!Account.Name} to the Allergan Moxie provider network.\n\nKind regards,\n{!User.FirstName} {!User.LastName}\nProvider Enrollment Team\nAllergan Moxie'
);

// ── Template C: Not Eligible ──────────────────────────────────────────────────

EmailTemplate tmplC = new EmailTemplate(
    Name            = 'AM - Product Access Not Eligible',
    DeveloperName   = 'AM_Product_Access_Not_Eligible',
    TemplateType    = 'text',
    FolderId        = UserInfo.getUserId(),
    IsActive        = true,
    Subject         = 'Product Access Review - Eligibility Determination - Case #{!Case.CaseNumber}',
    When_To_Use__c  = 'Use when notifying a provider that their practice does not currently meet eligibility requirements for a product or program, and to explain the 30-day dispute process.',
    Body            = 'Dear {!Contact.FirstName},\n\nThank you for contacting Allergan Moxie Provider Services regarding Case #{!Case.CaseNumber}.\n\nAfter reviewing your account and the details submitted for {!Account.Name}, we regret to inform you that based on our current eligibility criteria, your practice does not meet the requirements for the requested product or program at this time.\n\nThis determination was made based on one or more of the following factors:\n- Current credentialing status does not meet the minimum requirements for this product category.\n- The Medical Director\'s specialization does not fall within the approved scope for this product.\n- Required training or certification for this product has not been completed or is not on file.\n\nWe understand this may not be the outcome you were expecting, and we want to help you understand the path forward.\n\nNext steps to address eligibility:\n1. Please review the enclosed Allergan Moxie Eligibility Requirements document (Form AM-EL-010) to understand the specific criteria.\n2. If you believe this determination was made in error, please reply to this email with supporting documentation within 30 days and we will conduct a formal review.\n3. If you would like guidance on meeting the eligibility requirements, our Provider Services team is available to schedule a consultation.\n\nWe remain committed to supporting your practice and look forward to working with you.\n\nRegards,\n{!User.FirstName} {!User.LastName}\nProvider Services Representative\nAllergan Moxie'
);

insert new List<EmailTemplate>{ tmplA, tmplB, tmplC };

System.debug('');
System.debug('=== EMAIL TEMPLATES CREATED SUCCESSFULLY ===');
System.debug('Template A (Medical Director Change): ' + tmplA.Id + ' - ' + tmplA.Name);
System.debug('Template B (New Practice Enrollment): ' + tmplB.Id + ' - ' + tmplB.Name);
System.debug('Template C (Not Eligible):            ' + tmplC.Id + ' - ' + tmplC.Name);
System.debug('');
System.debug('When_To_Use__c values:');
System.debug('  A: ' + tmplA.When_To_Use__c);
System.debug('  B: ' + tmplB.When_To_Use__c);
System.debug('  C: ' + tmplC.When_To_Use__c);
