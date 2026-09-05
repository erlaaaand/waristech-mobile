Ya, referensi ini jauh lebih jelas. Arah yang tepat bukan menyalin desain secara literal, tetapi **mengambil visual language, hierarchy, spacing, card composition, dan bottom navigation dari referensi sekitar 85–90%**, lalu menyesuaikannya dengan konsep dan data WarisTech.

Berikut prompt final yang lebih tegas untuk diberikan ke coding/UI model:

# WarisTech Mobile — UI Redesign Master Prompt

## Reference-Based Premium Dashboard — 85–90% Visual Direction, Adapted to Existing Project

### ROLE

Act as a **Senior UI/UX Designer + Mobile Frontend Engineer + Design System Engineer**.

Your task is to redesign the existing **WarisTech Mobile** application based on the attached visual reference.

The attached image is the **primary visual reference** for the new dashboard.

Use the reference at approximately **85–90% visual fidelity in terms of design language and composition**, while adapting the remaining **10–15% to WarisTech's own product context, information architecture, existing components, backend data, and project constraints**.

The result must feel like:

> **“Inspired very strongly by the reference, but clearly redesigned for WarisTech.”**

Do **not** create a pixel-for-pixel copy.

Do **not** blindly reproduce elements that do not make sense for WarisTech.

---

# 1. CRITICAL RULE — PRESERVE THE EXISTING PROJECT

This is primarily a **UI/UX redesign task**, not a business-logic rewrite.

Before changing anything:

1. Inspect the existing project structure.
2. Understand the current routing/navigation.
3. Understand existing screens and widgets/components.
4. Understand the existing state management.
5. Understand existing backend/API integration.
6. Understand existing data models.
7. Understand existing asset logic.
8. Understand existing heir/notary relationships.
9. Understand existing check-in/proof-of-life logic.

Then:

> **Reuse the existing architecture and data flow wherever possible.**

### DO NOT change without a genuine functional requirement:

* backend API
* API endpoints
* request/response contracts
* database schema
* models
* repository/service layer
* authentication
* authorization
* business logic
* state management
* existing CRUD behavior
* existing navigation logic
* existing check-in logic
* existing asset logic
* existing role/permission logic

The new UI should sit **on top of the existing functionality**.

Architecture concept:

```text
EXISTING BACKEND
       ↓
EXISTING SERVICES
       ↓
EXISTING STATE MANAGEMENT
       ↓
EXISTING BUSINESS LOGIC
       ↓
NEW WARISTECH UI
```

The redesign must not reverse this relationship.

---

# 2. BACKEND IS THE SINGLE SOURCE OF TRUTH

Every dynamic element displayed on the dashboard must come from the existing project/backend.

Do not invent information simply to make the design look complete.

Never hardcode:

* user information
* heirs
* notary
* assets
* asset count
* asset names
* asset identifiers
* check-in status
* countdown
* balance
* recent data
* transaction information

unless it already exists as static product configuration.

### Important:

If backend says there are 2 saved assets, show 2 assets.

If backend says there are 5 saved assets, show 5.

If there are no assets, show an appropriate empty state.

If a field does not exist in backend:

> Do not create fake data to fill the UI.

Use:

```text
—
```

or an appropriate unavailable/empty state.

---

# 3. USE THE ATTACHED IMAGE AS THE PRIMARY VISUAL REFERENCE

The reference should strongly influence:

* overall composition
* top header structure
* greeting area
* hero card proportions
* card treatment
* action shortcuts
* avatar arrangement
* spacing rhythm
* typography hierarchy
* icon treatment
* bottom navigation
* soft/light premium aesthetic
* rounded component language
* visual density

Target:

```text
Reference visual language : ~85–90%
WarisTech adaptation        : ~10–15%
```

Do not interpret 85–90% as “copy every pixel”.

Instead reproduce the **design system and visual composition** while replacing inappropriate product elements.

---

# 4. WHAT MUST CHANGE FROM THE REFERENCE

The attached reference is a banking application.

WarisTech is **not a banking application**.

Therefore adapt the content and functionality accordingly.

### Reference:

```text
Balance
Quick Send
Bill
Mobile
More
Recent Activity
Banking transactions
```

### WarisTech:

```text
Asset Overview
Heirs
Notary / Relevant People
Asset Actions
Estate-related status
Existing WarisTech functionality
```

---

# 5. HERO CARD — ADAPT THE BALANCE CARD

The reference uses a large balance card.

For WarisTech:

> **Do NOT use the card to show a financial account balance.**

Instead, use this prominent card as an **Asset Vault / My Assets card**.

Its purpose is to represent the assets that have been saved by the heir/pewaris.

Example:

```text
┌─────────────────────────────────────┐
│                                     │
│  MY ASSETS                          │
│                                     │
│  Bank Account                       │
│  BCA ••••4821                       │
│                                     │
│                    SAVED ASSET      │
│                                     │
└─────────────────────────────────────┘
```

Or, if multiple assets exist:

```text
┌─────────────────────────────────────┐
│  MY ASSETS                          │
│                                     │
│  BANK ACCOUNT                       │
│  BCA                                │
│  •••• 4821                          │
│                                     │
│  2 / 5 ASSETS                       │
└─────────────────────────────────────┘
```

### IMPORTANT

The card should communicate:

> **“These are assets saved by this user.”**

It must NOT communicate:

> “This is the user's current bank balance.”

---

# 6. NEVER DISPLAY BANK ACCOUNT NOMINALS

Absolutely do not display:

```text
Rp 25.453.00
Rp 248.500.000
$25,453
Total Balance
Net Worth
Estimated Wealth
Total Portfolio
```

The redesign must **not introduce financial valuation logic**.

Only display asset information that already exists in the backend.

Possible information:

```text
Asset Type
Asset Name
Provider
Masked Account / Identifier
Status
Metadata
```

Use whatever fields actually exist in the project.

Do not infer missing values.

---

# 7. HERO CARD VISUAL STYLE

The reference's card composition should remain strongly recognizable.

Use:

* large rounded card
* prominent visual hierarchy
* dark/premium card surface where appropriate
* subtle texture/gradient
* strong typography
* small metadata
* small decorative accent
* compact action affordance

However adapt its visual identity to WarisTech.

Recommended aesthetic:

```text
Deep Navy
Dark Blue
Rich Blue
Black
Subtle Green / Lime accent where appropriate
Soft gradient
```

Do not blindly reproduce the card graphics from the reference.

Create a **WarisTech asset-vault interpretation**.

---

# 8. QUICK SEND → HEIRS

The reference's **Quick Send** section must be completely replaced.

Do not use:

```text
Quick Send
Send
Bill
Mobile
```

Instead:

# AHLI WARIS

This section should display the heirs associated with the current user/pewaris.

Example:

```text
AHLI WARIS                         Lihat semua >

[A] [C] [F] [H] [N]

Azie   Chair   Fandi   Happy   Nayu
```

The visual treatment should strongly resemble the reference's **Quick Send avatar row**, but the information architecture must belong to WarisTech.

### Important

The data must come from the existing backend.

Do not hardcode heirs.

Do not assume the number of heirs.

If there are 3 heirs, render 3.

If there are 10, support scrolling or the existing appropriate interaction.

If no heirs exist:

```text
Belum ada ahli waris
```

using an appropriate existing flow/CTA.

---

# 9. HEIR AVATAR DESIGN

Follow the reference closely in terms of presentation:

* circular avatars
* compact spacing
* horizontal arrangement
* small names underneath
* clean white/light background
* subtle visual hierarchy

Possible fallback:

```text
A
C
F
```

using initials when profile photos are unavailable.

The component should feel like a **trusted relationship/contact section**, not a social-media friend list.

---

# 10. QUICK ACTIONS

The reference contains a row of circular quick-action buttons.

WarisTech should retain the **same visual concept**, but the actions must correspond to functionality that already exists in the project.

Possible actions, only when supported by the existing application:

```text
Asset
Heir
Check-In
More
```

or:

```text
Assets
Ahli Waris
Dokumen
More
```

### CRITICAL

Do not create new business functions merely because the reference contains them.

Only expose actions that have an existing WarisTech implementation.

The UI should adapt to the existing functionality, not the other way around.

---

# 11. REMOVE RECENT ACTIVITY

The reference contains:

```text
Recent Activity
Food Store
House Rent
Transactions
```

This section must be **removed from the WarisTech dashboard**.

Do not replace it with fake transaction history.

Do not create a banking activity feed.

Do not invent an alternative activity list unless an equivalent WarisTech backend feature already exists.

After the asset/heir section, allow the screen to breathe.

Use whitespace deliberately.

---

# 12. TOP HEADER

Follow the reference strongly.

Structure:

```text
[Profile / Avatar]    Greeting / User Name
                      Welcome Back

                                      [Action]
```

The exact content must use the existing WarisTech user data.

Example:

```text
Good morning,
Sinde

Welcome back
```

Do not hardcode user names.

### Visual direction

* compact profile area
* small avatar
* small secondary text
* strong greeting typography
* generous whitespace
* light/premium background

Keep it visually close to the reference without copying its content.

---

# 13. DASHBOARD BACKGROUND

Unlike the earlier dark-only WarisTech concept, this reference suggests a **light premium dashboard**.

Adopt this visual direction for the dashboard:

```text
Soft off-white
Very light mint
Subtle green tint
Very light gray
```

Use the darker premium colors primarily for:

* hero card
* typography
* navigation
* selected elements
* important actions

This creates a contrast:

```text
LIGHT PREMIUM CANVAS
+
DARK HERO CARD
+
DARK FLOATING NAVIGATION
```

The result should feel significantly closer to the attached reference.

---

# 14. CARD CORNERS & SHAPE LANGUAGE

Use strong rounded geometry throughout.

Recommended:

```text
Large cards       : 20–28px
Buttons           : 999px / pill
Avatar            : 50%
Quick actions     : circular
Navigation        : 999px
```

Avoid sharp rectangular components unless the existing WarisTech component requires them.

---

# 15. BOTTOM NAVIGATION — FOLLOW THE REFERENCE

The bottom navigation should be strongly inspired by the image.

Do not use a conventional full-width bottom AppBar.

Instead:

> Create a compact **floating dark pill navigation**.

Example:

```text
        ┌────────────────────────────┐
        │   Home   Assets   Check   More │
        └────────────────────────────┘
```

Visual characteristics:

* floating
* dark background
* pill shape
* circular/soft active state
* subtle shadow
* compact width
* positioned above the bottom safe area
* visually similar to the reference

Target:

```text
Height: approximately 58–66px
Bottom spacing: approximately 18–26px
Radius: 999px
```

---

# 16. BOTTOM NAV ACTIVE STATE

Follow the reference's visual behavior.

Active tab should have:

* stronger contrast
* circular or capsule highlight
* brighter icon
* clear visual focus

Inactive tabs:

* lower contrast
* simple icon
* minimal visual weight

The animation should be subtle:

```text
scale
fade
indicator movement
```

Do not change the underlying navigation routes.

Only redesign how the existing routes are represented visually.

---

# 17. VISUAL HIERARCHY

The new dashboard hierarchy should be:

```text
1. Greeting / User
2. Main Asset Card
3. Quick Actions
4. Ahli Waris
5. Optional existing WarisTech information
6. Floating Navigation
```

Do not force additional information into the dashboard.

The screen should feel spacious like the reference.

---

# 18. EXACT ADAPTATION MAP

Use this mapping while implementing:

| Reference Element     | WarisTech Replacement                      |
| --------------------- | ------------------------------------------ |
| Welcome / Greeting    | Existing WarisTech user greeting           |
| Balance Card          | Saved Assets Card                          |
| Balance Amount        | REMOVE                                     |
| Card Number           | Masked asset identifier, only if available |
| Quick Send            | Ahli Waris                                 |
| Send                  | Existing WarisTech action                  |
| Bill                  | Existing WarisTech action if available     |
| Mobile                | Existing WarisTech action if available     |
| More                  | Existing WarisTech secondary actions       |
| Recent Activity       | REMOVE                                     |
| Transactions          | REMOVE                                     |
| Banking data          | Existing WarisTech data                    |
| Bottom App Navigation | Floating pill navigation                   |
| Banking aesthetic     | WarisTech estate-management aesthetic      |

---

# 19. DATA-DRIVEN ASSET CARD

The asset card must be dynamic.

Concept:

```text
Backend
   ↓
assets[]
   ↓
Asset Card UI
```

Do not hardcode:

```text
BCA
Bank Account
•••• 4821
```

unless those values actually exist in the backend.

The example above is purely illustrative.

---

# 20. EMPTY ASSET STATE

When the user has no saved assets:

```text
MY ASSETS

No assets added yet

Add an asset to start organizing
your estate.
```

Use the existing asset creation flow.

Do not create a new route unless necessary.

---

# 21. RESPONSIVENESS

The design must remain visually faithful to the reference on:

```text
360 × 800
390 × 844
412 × 915
430 × 932
```

Pay special attention to:

* card width
* avatar spacing
* quick action spacing
* navigation width
* safe area
* vertical scrolling
* keyboard interaction
* dynamic asset count

Never allow bottom navigation to overlap important content.

---

# 22. DO NOT OVERFIT TO THE REFERENCE

The reference is a **design reference**, not a specification for WarisTech functionality.

Use it for:

```text
Visual language
Composition
Spacing
Hierarchy
Cards
Shape
Navigation
Interaction feel
```

Do not use it for:

```text
Business logic
Banking functionality
Transaction logic
Data schema
User flows
API structure
```

---

# 23. “85–90% REFERENCE, 10–15% WARISTECH”

The final design should visually remind the user strongly of the reference.

However, it should also communicate:

> **This is WarisTech, not the original banking application.**

The adaptation should come from:

* WarisTech terminology
* heir relationships
* asset vault concept
* proof-of-life/check-in functionality where applicable
* existing backend data
* existing navigation
* existing WarisTech workflows
* WarisTech brand identity

Do not add random decorative elements merely to differentiate the design.

---

# 24. MICRO-INTERACTIONS

Use subtle interactions inspired by modern premium mobile apps.

Examples:

### Card

```text
Press:
1.0 → 0.97 → 1.0
```

### Avatar

Subtle scale on interaction.

### Bottom Navigation

Smooth active-state transition.

### Asset Selection

Subtle elevation/scale transition.

### Loading

Use inline/component loading.

Do not rewrite async logic.

---

# 25. ACCESSIBILITY

Even though the reference is highly visual, usability is mandatory.

Ensure:

* readable text
* adequate contrast
* touch targets around 44px or greater
* accessible labels for icons
* meaningful states
* dynamic content support
* no information communicated through color alone

---

# 26. IMPLEMENTATION WORKFLOW

Before coding:

```text
Inspect existing project
        ↓
Understand architecture
        ↓
Understand backend
        ↓
Understand state management
        ↓
Understand current dashboard
        ↓
Identify reusable components
        ↓
Map existing data to new UI
        ↓
Implement visual redesign
        ↓
Test existing functionality
```

After implementation verify:

```text
Login works
Authentication works
Navigation works
Assets load correctly
Assets remain dynamic
Heirs load correctly
Check-in works
Existing actions work
Backend requests remain unchanged
No fake data exists
No bank balance is displayed
No recent activity is fabricated
```

---

# 27. FINAL NON-NEGOTIABLE INSTRUCTION

> **Redesign the existing WarisTech dashboard using the attached reference as an 85–90% visual direction, but adapt the design to WarisTech's actual product and existing project.**

> **Do not clone the reference pixel-for-pixel.**

> **Do not change the application's existing logic merely to reproduce the reference.**

> **Do not modify backend APIs, database schemas, business logic, state management, authentication, navigation behavior, or existing workflows unless absolutely required by an existing project issue.**

> **Use the existing backend and state as the single source of truth.**

> **Replace the reference's Balance card with a premium Saved Assets card. Do not display bank balances, nominal amounts, total wealth, net worth, or fabricated financial values.**

> **Replace Quick Send with the actual Ahli Waris belonging to the current Pewaris.**

> **Remove Recent Activity entirely from the dashboard.**

> **Use the reference's compact floating dark bottom navigation as the primary visual direction for WarisTech's Home Bar, while preserving the existing navigation functionality.**

> **The goal is not to make WarisTech look identical to the reference. The goal is to make WarisTech feel like it belongs to the same premium design family while remaining functionally and visually appropriate to its own product.**

### Final Quality Target

```text
REFERENCE
≈ 85–90% visual influence

WARISTECH
≈ 10–15% contextual adaptation

EXISTING LOGIC
= 100% PRESERVED
```

**Think:**

> *“Same design DNA, different product.”*
