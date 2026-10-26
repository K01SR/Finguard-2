# FinGuard — Financial Transaction Anomaly Detection & Fraud Prevention

ML-based fintech platform that scores financial transactions in real-time for suspicious behavior, serving verdicts through a high-performance REST API and an interactive live React dashboard.

**Model performance:** Precision 1.00, Recall 0.87, **F1 0.93, ROC-AUC 0.94** (6,000 transactions, 6% fraud baseline; see `models/metrics.json`).

---

## Architecture

```
Transaction → Feature Engineering (18-dim vector)
            → Tri-Model Ensemble:
                • XGBoost Classifier (55%)
                • Isolation Forest Anomaly Index (25%)
                • Deep MLP Autoencoder Reconstruction (20%)
            → Risk Engine → APPROVE (<0.35) / REVIEW (0.35-0.70) / BLOCK (≥0.70)
            → FastAPI Asynchronous Inference Server (<15ms latency)
            → React 18 Telemetry Dashboard (Recharts + Live Stream)
            → Dual Persistence: PostgreSQL or Automatic CSV Fallback
```

---

## Deploy on Render (Free Tier Single Web Service)

FinGuard is configured to deploy as a **single, unified all-in-one Docker container** on [Render](https://render.com), hosting both the React frontend and FastAPI backend without needing separate services or paid databases.

### Step 1: Push to GitHub
Ensure your repository is pushed to GitHub:
```bash
git push -u origin master
```

### Step 2: Deploy on Render
1. Log in to your [Render Dashboard](https://dashboard.render.com/).
2. Click **New +** → **Web Service**.
3. Connect your GitHub repository: `Finguard-2`.
4. Render will automatically detect `render.yaml` (or select **Runtime: Docker**).
5. Instance Type: Select **Free**.
6. Click **Create Web Service**.

Render will automatically build the multi-stage Docker image, compile the frontend, train the anomaly detection models, and deploy the application with a public HTTPS URL (e.g. `https://finguard.onrender.com`).

---

## Add DuckDNS Domain on Render (`finguarddd.duckdns.org`)

To link your `finguarddd.duckdns.org` domain to your Render deployment with free automated SSL/TLS (HTTPS):

1. **In Render Dashboard**:
   - Go to your Web Service → **Settings** → **Custom Domains**.
   - Click **Add Custom Domain** and enter: `finguarddd.duckdns.org`.
   - Render will display the DNS instructions:
     - Target CNAME: `finguard-xxxx.onrender.com` (or A record IP: `216.24.57.1`).

2. **In DuckDNS**:
   - Log in to [duckdns.org](https://www.duckdns.org).
   - In your `finguarddd` domain entry, set the IP address to Render's Ingress IP: `216.24.57.1` (or use the DuckDNS token update API):
     ```bash
     curl "https://www.duckdns.org/update?domains=finguarddd&token=YOUR_DUCKDNS_TOKEN&ip=216.24.57.1"
     ```
3. Once DNS propagates (1-2 minutes), Render automatically provisions a free Let's Encrypt certificate, and your site is live at:
   `https://finguarddd.duckdns.org`

---

## Local Development (All-in-One Docker)

To run the whole stack locally in a single Docker container:

```bash
# Build and launch unified container (frontend + backend)
docker compose up -d

# Verify container status
docker ps
```

The application is immediately available at:
- **Web Dashboard**: `http://localhost:8000` or `http://localhost`
- **Swagger API Docs**: `http://localhost:8000/docs`
- **Health Check**: `http://localhost:8000/health`

---

## API Contract

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/predict` | Score a single transaction |
| `POST` | `/predict/batch` | Score a batch of transactions |
| `GET` | `/stats` | Aggregated metrics, risk mix, and merchant category averages |
| `GET` | `/recent?limit=50` | Reverse-chronological audit log of scored transactions |
| `GET` | `/metrics` | Trained machine learning model evaluation metrics |
| `GET` | `/health` | System health and model readiness probe |

### Example Request (`POST /predict`):
```json
{
  "user_id": "U102",
  "amount": 120000,
  "merchant_category": "electronics",
  "location": "London",
  "device": "unknown",
  "transaction_hour": 3,
  "prev_amount": 2000
}
```

### Response:
```json
{
  "transaction_id": "TXN9481",
  "anomaly_score": 0.9997,
  "risk_level": "HIGH",
  "decision": "BLOCK",
  "signals": {
    "supervised_prob": 0.9994,
    "if_score": -0.2004,
    "ae_error": 46.5855
  }
}
```

---

## Project Report (30+ Pages)

A comprehensive academic project report conforming to the University of Mumbai / Bharat College of Engineering guidelines (including 13 publication figures, 9 tables, mathematical derivations, and Gantt charts) is available at:
- `FinGuard_Complete_Project_Report_30_Pages.docx` (in this repository)
- `~/Downloads/FinGuard_Complete_Project_Report_30_Pages.docx`

---

## License

MIT License.
