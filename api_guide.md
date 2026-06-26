# Crypto Mining App - API Endpoints Guide

## 🔗 Base URL Configuration
- **Production Base URL**: `https://yourdomain.com/api`
## 🔐 Authentication Format
For all protected routes, the Flutter app must send the JWT Access Token in the Headers:
```json
{
  "Authorization": "Bearer <YOUR_ACCESS_TOKEN>"
}
```
---
## 1. Authentication APIs (`/api/auth`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **POST** | `/auth/register` | Public | Register with name, email, password, and optional referral code |
| **POST** | `/auth/login` | Public | Login with email and password |
| **POST** | `/auth/google` | Public | Login using Google OAuth ID token |
| **POST** | `/auth/facebook` | Public | Login using Facebook Access token |
| **POST** | `/auth/apple` | Public | Login using Apple Identity token |
| **POST** | `/auth/refresh-token`| Public | Get a new access token using a refresh token |
| **GET**  | `/auth/verify-email` | Public | Verify user email address |
| **POST** | `/auth/forgot-password`| Public | Request password reset email |
| **POST** | `/auth/reset-password` | Public | Reset password using token |
| **POST** | `/auth/logout` | **Protected** | Logout and invalidate refresh token |
| **POST** | `/auth/change-password`| **Protected** | Change password for logged-in user |
| **GET**  | `/auth/me` | **Protected** | Get current logged-in user profile details |
---
## 2. Mining APIs (`/api/mining`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **GET**  | `/mining/ad-token` | **Protected** | Get an anti-cheat token *before* showing the rewarded ad |
| **POST** | `/mining/start` | **Protected** | Start mining session (Pass `adToken` from above step) |
| **POST** | `/mining/stop` | **Protected** | Manually stop current mining session |
| **GET**  | `/mining/status` | **Protected** | Get current active mining session details |
| **GET**  | `/mining/history` | **Protected** | Get paginated history of past mining sessions |
---
## 3. Subscription & Premium APIs (`/api/subscriptions`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **GET**  | `/subscriptions/plans` | **Protected** | List all available premium plans (Starter, Silver, etc.) |
| **POST** | `/subscriptions/purchase` | **Protected** | Buy a plan (Pass `planName` and payment details) |
| **GET**  | `/subscriptions/current` | **Protected** | Get the user's currently active subscription |
| **GET**  | `/subscriptions/history` | **Protected** | Get history of purchased subscriptions |
---
## 4. Wallet APIs (`/api/wallet`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **GET**  | `/wallet/balance` | **Protected** | Get wallet balances (Mining, Referral, Total, etc.) |
| **GET**  | `/wallet/transactions`| **Protected** | Get full transaction ledger with pagination |
---
## 5. Withdrawals APIs (`/api/withdrawals`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **POST** | `/withdrawals/request` | **Protected** | Submit a withdrawal request (wallet address & amount) |
| **GET**  | `/withdrawals/history` | **Protected** | Get history of withdrawal requests and their statuses |
---
## 6. Referral APIs (`/api/referrals`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **GET**  | `/referrals/info` | **Protected** | Get user's referral code and top-level stats |
| **GET**  | `/referrals/users` | **Protected** | Get list of users referred by this user |
| **GET**  | `/referrals/rewards` | **Protected** | Get breakdown of referral rewards earned |
---
## 7. Notifications APIs (`/api/notifications`)
| Method | Endpoint | Protection | Description |
|--------|----------|------------|-------------|
| **GET**  | `/notifications/` | **Protected** | Get paginated list of user notifications |
| **GET**  | `/notifications/unread-count`| **Protected** | Get count of unread notifications |
| **PATCH**| `/notifications/read-all` | **Protected** | Mark all notifications as read |
| **PATCH**| `/notifications/:id/read` | **Protected** | Mark specific notification as read |
| **DELETE**| `/notifications/:id` | **Protected** | Delete a specific notification |
---
## ⚡ Socket.IO (Real-Time Mining Engine)
To show the live mining balance ticking up in real-time, the Flutter app must connect to the Socket.io server.
### 1. Connection
Connect to the base URL and pass the JWT token in the `auth` object:
```javascript
// Flutter equivalent Socket.io setup
Socket socket = io('http://localhost:5000',
    OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': 'YOUR_JWT_ACCESS_TOKEN'}) // VERY IMPORTANT
      .build()
);
```
### 2. Events to Listen For
Listen to the `miningTick` event. The server emits this event exactly **once every second** while the user is actively mining.
```json
// Event Name: 'miningTick'
// Response Payload Example:
{
  "currentMiningBalance": "0.00001234",
  "currentSpeed": "1.5", 
  "remainingTime": 14399, // Time left in seconds
  "status": "MINING"
}
```
### 3. Events to Emit (Optional)
If you want to manually trigger an update request from the frontend:
- Emit Event: `requestMiningStatus` (Server will instantly respond with a `miningTick` payload).
