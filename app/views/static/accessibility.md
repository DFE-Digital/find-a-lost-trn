<% content_for :page_title, 'Accessibility statement' %>

# Accessibility statement for <%= t('tra.service_name') %>

This page only contains information about the <%= t('tra.service_name') %>
service, available at: <a href="<%= t('tra.url') %>" class="govuk-link
govuk-link--no-visited-state"> <%= t('tra.url') %> </a>

## Using this service

This service is run by the Department for Education. We want as many people as
possible to be able to use this service.

For example, that means you should be able to:

- change colours, contrast levels and fonts
- zoom in up to 300% without the text spilling off the screen
- get from the start of the service to the end using just a keyboard
- get from the start of the service to the end using speech recognition
  software
- listen to the service using a screen reader (including the most recent
  versions of JAWS, NVDA and VoiceOver)

We’ve also made the text in the service as simple as possible to understand.

[AbilityNet](https://mcmw.abilitynet.org.uk/) has advice on making your device
easier to use if you have a disability.

## How accessible this service is

This service is fully compliant with [the Web Content Accessibility Guidelines
version 2.2 AA standard](https://www.w3.org/TR/WCAG22/).

## Feedback and contact information

If you have difficulty using this service, email: <a href="mailto:<%=
t('tra.email') %>" class="govuk-link govuk-link--no-visited-state"><%=
t('tra.email') %></a>

As part of providing this service, we may need to send you messages or
documents. We'll ask you how you want us to send messages or documents to you,
but contact us if you need them in a different format, for example, large print,
audio recording or braille.

## Reporting accessibility problems with this service

We’re always looking to improve the accessibility of this service.

If you find any problems that are not listed on this page or think we’re not
meeting accessibility requirements, email: <a href="mailto:<%= t('tra.email')
%>" class="govuk-link govuk-link--no-visited-state"><%= t('tra.email') %></a>

## Enforcement procedure

The Equality and Human Rights Commission (EHRC) is responsible for enforcing
the Public Sector Bodies (Websites and Mobile Applications) (No. 2)
Accessibility Regulations 2018 (the ‘accessibility regulations’).

If you’re not happy with how we respond to your complaint, contact [the
Equality Advisory and Support Service
(EASS)](https://www.equalityadvisoryservice.com/).

## Technical information about this service’s accessibility

The Department for Education is committed to making this service accessible, in
accordance with the Public Sector Bodies (Websites and Mobile Applications)
(No. 2) Accessibility Regulations 2018.

### Compliance status

This service is fully compliant with [the Web Content Accessibility Guidelines
version 2.2 AA standard](https://www.w3.org/TR/WCAG22/).

## Non-accessible content

The content listed below is non-accessible for the following reasons.

### Non-compliance with the accessibility regulations

When encountering an error message, browser focus is moved to an error summary.
In NVDA and VoiceOver, this reads out the error summary heading, which says
"There is a problem," as well as a list of individual error messages, such as
"Tell us if you think you have a TRN." This meets [WCAG 2.1 success criterion
3.3.1 (error
identification)](https://www.w3.org/WAI/WCAG21/Understanding/error-identification.html).

However, in JAWS 2022 in Windows 11, only the error summary heading is read out
by the screen reader. This fails criterion 3.3.1, specifically that the user
cannot immediately determine what is wrong:

> "The intent of this Success Criterion is to ensure that users are aware that
> an error has occurred and **can determine what is wrong.**"

As we are using the error summary pattern from the GOV.UK Design System, we are
[investigating this issue with the upstream design system
team](https://github.com/alphagov/govuk-frontend/issues/2657).

### Disproportionate burden

There are no known accessibility problems in our service that we consider would
be a disproportionate burden to fix.

### Content that’s not within the scope of the accessibility regulations

There is no content in our service that's not within the scope of the
accessibility regulations.

## What we are doing to improve accessibility

We’ll carry out ongoing internal audits to check the accessibility of this
service as well as taking feedback from users.

Any required changes will be planned into our continuous improvement work for
this service.

This accessibility statement will be updated based on any issues we identify or
any changes we make to address any issues raised.

## Preparation of this accessibility statement

This statement was prepared on Tuesday 5 April 2022. It was last reviewed on
Tuesday 7 June 2022.

This service was last tested on Thursday 16 May 2022. The test was carried
out by the DFE Accessibility team.

Last updated: Tuesday 7 June 2022
