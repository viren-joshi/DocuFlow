# DocuFlow: Serverless Document Approval Workflow System

DocuFlow is a fully serverless, cloud-native document approval system built on AWS. It streamlines document submissions, multi-level approvals, notifications, and version control for internal enterprise workflows. The system aims to be lightweight, scalable, and cost-efficient, making it ideal for organizations seeking automated and auditable document lifecycle management without managing servers or complex infrastructure.

---

## 🚀 Project Overview

Organizations often require secure, traceable, and efficient document approval workflows. Existing solutions are either too complex or lack internal enterprise focus. DocuFlow addresses this by offering:

- Document submission with versioning
- Automated approval workflows
- Email notifications for approvers
- Immutable audit trails for compliance
- Fully serverless, auto-scaling infrastructure

---

## 📋 Key Features

- Multi-level approval with automated workflow and decision tracking
- Secure file storage with versioning
- Email notifications with approval links
- Real-time document status tracking via APIs
- Fully stateless and serverless deployment


---

## 📂 Architecture Overview

DocuFlow is designed with a **modular serverless architecture**:

> ![Final Architecture](https://github.com/user-attachments/assets/9f9fbfd8-00bc-4cae-a0f0-319bf4cc0439)
> DocuFlow AWS Architecture


- **Frontend**
  - React Single-Page Application (SPA)
  - Hosted on **Amazon S3 Static Website Hosting**

- **User Authentication**
  - **Amazon Cognito** for:
    - Secure user sign-up and sign-in
    - JWT-based API authorization

- **API Layer**
  - **Amazon API Gateway** to:
    - Route API requests to backend services
    - Enforce authentication via Cognito JWT tokens

- **Backend Services**
  - Multiple **AWS Lambda** functions for:
    - Document uploads and downloads
    - Approval submissions and decisions
    - Workflow orchestration
    - Document status queries

- **Document Storage**
  - **Amazon S3** with:
    - Versioning for historical revisions
    - Lifecycle policies for cost optimization

- **Approval Workflow**
  - **AWS Step Functions** for:
    - Orchestrating multi-approver document approval processes
    - Handling retries and error paths

- **Database**
  - **Amazon DynamoDB** for:
    - Document metadata storage
    - Approval status tracking
    - Task token and audit log persistence

- **Email Notification**
  - Integration with **Resend API** (due to SES restrictions) for:
    - Sending approval notifications via email
    - Delivering personalized approval links

- **Monitoring & Logging**
  - **Amazon CloudWatch** for:
    - Centralized logging
    - Custom dashboards and metrics
    - Alarms for monitoring system health

- **Infrastructure as Code**
  - Fully provisioned and managed with **Terraform (HCL)**

---

## 🗂️ Core AWS Services Used

| Service Category         | Services Used                                         |
|--------------------------|-------------------------------------------------------|
| **Compute**              | AWS Lambda                                           |
| **Storage**              | Amazon S3                                            |
| **Database**             | Amazon DynamoDB                                      |
| **Networking & Delivery**| Amazon API Gateway, Amazon VPC                       |
| **Application Integration** | AWS Step Functions, Resend Email API              |
| **Security & Identity**  | Amazon Cognito, IAM                                  |
| **Monitoring & Governance** | Amazon CloudWatch                                |


---

## 📊 Well-Architected Framework Compliance

- **Operational Excellence**
  - Modular, serverless design
  - Centralized monitoring via CloudWatch dashboards and alarms

- **Security**
  - User authentication and authorization with Amazon Cognito
  - Secure document access via pre-signed S3 URLs
  - Restricted access to backend APIs and resources

- **Reliability**
  - Stateless, serverless architecture ensuring high availability
  - Resilient workflows with built-in fallback mechanisms (e.g., implicit rejection)

- **Performance Efficiency**
  - Parallel processing of document approvals using Step Functions
  - Auto-scaling with AWS Lambda to handle varying workloads

- **Cost Optimization**
  - Fully serverless architecture eliminates idle infrastructure costs
  - Pay-per-use pricing model for Lambda, API Gateway, and other services

- **Sustainability**
  - Efficient use of compute resources with serverless services
  - Document versioning reduces redundant storage
  - Minimal operational overhead and energy consumption


---


## ⚙️ Lambda Functions

### Document Access & Workflow
| Function Name           | Purpose                                                                 |
|-------------------------|-------------------------------------------------------------------------|
| `getViewDocumentUrl`    | Generates pre-signed S3 URL for viewing documents securely              |
| `getUploadDocumentUrl`  | Generates pre-signed S3 URL for document uploads                        |
| `submitDocument`        | Starts approval workflow via Step Function                              |
| `approveDocument`       | Handles document approval/rejection and updates state                   |
| `getApprovalDocuments`  | Lists documents pending or processed for current user                   |
| `getSubmittedDocuments` | Lists documents submitted by the current user                           |

### Step Function Orchestration
| Function Name           | Purpose                                                                 |
|-------------------------|-------------------------------------------------------------------------|
| `notifyUsers`           | Sends emails with approval links and stores task tokens in DynamoDB      |
| `implicitRejection`     | Marks approvals as rejected when errors/timeouts occur                   |
| `evaluateApprovalOutcome` | Finalizes document status based on collected approvals                 |

## 🔄 Step Function Workflow

The **AWS Step Functions** state machine orchestrates the document approval process. It ensures parallel, traceable, and resilient multi-approver workflows.

> <img src="https://github.com/user-attachments/assets/1e1d12bd-3573-4ff7-8394-ebeab9cdc3b4" alt="StepFunction - DocuFlow State Machine" width="350" height="300"> <br>
> Step Function - DocuFlow State Machine Definition

### Workflow Overview:
- Maps over all approvers to initiate parallel approval requests
- Sends approval emails with task tokens
- Waits for approval responses or timeouts
- Handles implicit rejections and errors gracefully
- Finalizes document status after all responses

### Key States in the State Machine:
| State Name             | Purpose                                                                                     |
|------------------------|---------------------------------------------------------------------------------------------|
| `NotifyApprovers (Map)` | Iterates over each approver, triggers `notifyUsers` Lambda, and sends email with approval link |
| `WaitForApproval`    | Waits for each approver’s action using task tokens (approval/rejection)                      |
| `Implicit Rejection` (Catch Path) | Automatically rejects remaining approvals if an approver rejects or an error occurs     |
| `EvaluateApprovalOutcome` | Aggregates results from all approvers via `evaluateApprovalOutcome` Lambda; finalizes status |

### Highlights:
- **Timeouts:** Each approval has a 7-day expiration to prevent indefinite waiting
- **Parallelism:** Supports multiple approvers simultaneously using `Map` state
- **Fallbacks:** Implicit rejection ensures workflow completes even on failures
- **Scalability:** Serverless design enables handling high volumes of workflows

---

## 💸 Cost Estimate

| Estimated Monthly Usage (Per 1,000 Users) | Estimated Monthly Cost |
|-------------------------------------------|------------------------|
| Lambda, S3, DynamoDB, Step Functions, etc.| ~$2 per 1,000 users    |

---

## 📝 Future Improvements

- Document grouping, tags, and advanced filters
- Verified domains for branded, trusted email delivery
- Integration with Slack/Microsoft Teams for approvals
- More robust audit reports and metrics

---

## 📸 Implementation

> ![Screenshot 2025-07-04 195557](https://github.com/user-attachments/assets/cb98250e-ddf2-4253-b579-cec535ff85bf)
> Documents Submitted For Approval

> ![Screenshot 2025-07-04 200009](https://github.com/user-attachments/assets/50cee1a7-fae9-44ac-b3ff-cec4f1d67e26)
> View Approved Documents

> ![image](https://github.com/user-attachments/assets/ae22073d-dac0-4d94-8394-70b4c6f0d7e5)
> Submit a document for approval

>![image](https://github.com/user-attachments/assets/82d72542-6232-4d47-816f-a02831b7c2d2)
> View Documents to approve

>![image](https://github.com/user-attachments/assets/be44ca24-b057-4a1f-baeb-7b735aab2f38)
> Approve / Reject Document
