# خطة إعادة تصميم نظام الفواتير

## 📋 نظرة عامة
إعادة تصميم نظام الفواتير ليكون أكثر تنظيماً وسهولة في الاستخدام مع تقسيم الفواتير إلى ثلاث صفحات منفصلة.

## 🗂️ هيكل الصفحات الجديد

### 1. الصفحات الثلاث
```
lib/presentation/pages/bills/
├── unpaid_bills_page.dart      # الفواتير غير المدفوعة
├── under_review_bills_page.dart # الفواتير تحت المراجعة  
└── paid_bills_page.dart        # الفواتير المدفوعة
```

### 2. تقسيم الوظائف
- **صفحة الفواتير غير المدفوعة**: عرض + زر دفع
- **صفحة الفواتير تحت المراجعة**: عرض فقط
- **صفحة الفواتير المدفوعة**: عرض فقط

## 🗄️ تعديلات قاعدة البيانات

### 1. حذف الجداول غير المستخدمة
```sql
-- حذف الجداول القديمة
DROP TABLE IF EXISTS batch_bill_items CASCADE;
DROP TABLE IF EXISTS batch_bills CASCADE;
```

### 2. إنشاء جدول طلبات الدفع الجديد
```sql
CREATE TABLE bill_payment_requests (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_id UUID NOT NULL REFERENCES bills(bill_id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(parent_id) ON DELETE CASCADE,
    bank_id UUID NOT NULL REFERENCES banks(bank_id),
    transfer_number VARCHAR(100) NOT NULL,
    receipt_image_path TEXT,
    requested_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    processed_by UUID,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3. إنشاء جدول الفواتير المدفوعة
```sql
CREATE TABLE paid_bills (
    paid_bill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_bill_id UUID NOT NULL,
    parent_id UUID NOT NULL REFERENCES parents(parent_id) ON DELETE CASCADE,
    bill_number VARCHAR(50) NOT NULL,
    bill_description TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    paid_amount DECIMAL(10,2) NOT NULL,
    bank_id UUID REFERENCES banks(bank_id),
    transfer_number VARCHAR(100),
    receipt_image_path TEXT,
    payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4. تبسيط جدول الفواتير الرئيسي
```sql
-- إزالة الأعمدة غير الضرورية
ALTER TABLE bills 
DROP COLUMN IF EXISTS bank_id,
DROP COLUMN IF EXISTS transfer_number,
DROP COLUMN IF EXISTS receipt_image_path,
DROP COLUMN IF EXISTS paid_amount,
DROP COLUMN IF EXISTS paid_at,
DROP COLUMN IF EXISTS payment_notes;
```

## 🔧 الدوال المطلوبة

### 1. دالة إرسال طلب دفع فاتورة
```sql
CREATE FUNCTION submit_bill_payment_request(
    p_bill_id UUID,
    p_parent_id UUID,
    p_bank_id UUID,
    p_transfer_number TEXT,
    p_receipt_image_path TEXT,
    p_amount DECIMAL
) RETURNS UUID
```

### 2. دالة عرض الفواتير تحت المراجعة
```sql
CREATE FUNCTION get_bills_under_review(p_parent_id UUID)
RETURNS TABLE(...)
```

### 3. دالة عرض الفواتير المدفوعة
```sql
CREATE FUNCTION get_paid_bills(p_parent_id UUID)
RETURNS TABLE(...)
```

### 4. دالة تأكيد الدفع (للإدارة)
```sql
CREATE FUNCTION approve_payment_request(p_request_id UUID)
RETURNS BOOLEAN
```

## 🔄 التريجر المطلوب

### تريجر نقل الفاتورة إلى المدفوعة عند الموافقة
```sql
CREATE TRIGGER move_bill_to_paid
AFTER UPDATE OF status ON bill_payment_requests
FOR EACH ROW
WHEN (NEW.status = 'approved')
EXECUTE FUNCTION move_bill_to_paid_table();
```

## 🎨 تصميم واجهة المستخدم

### 1. شاشة الدفع المنبثقة
```
┌─────────────────────────────────┐
│ 💳 دفع الفاتورة                │
├─────────────────────────────────┤
│ 🏦 اختيار البنك                │
│ [قائمة منسدلة للبنوك]           │
├─────────────────────────────────┤
│ 📷 إرفاق صورة الإيصال          │
│ [منطقة رفع الصورة + معاينة]      │
├─────────────────────────────────┤
│ 🔢 رقم الإيصال                 │
│ [حقل إدخال النص]                │
├─────────────────────────────────┤
│ 💰 المبلغ المدفوع              │
│ [حقل ثابت غير قابل للتعديل]      │
├─────────────────────────────────┤
│     [إرسال] [إلغاء]             │
└─────────────────────────────────┘
```

### 2. الأنيميشن المطلوب
1. اختيار البنك → ظهور منطقة رفع الصورة
2. رفع الصورة → ظهور حقل رقم الإيصال
3. إدخال الرقم → ظهور المبلغ وزر الإرسال

## 📱 تطبيق المحمول

### 1. التنقل بين الصفحات
- استخدام TabBar أو PageView للتنقل
- أيقونات مميزة لكل صفحة
- عدادات للفواتير في كل تبويب

### 2. التفاعل والاستجابة
- Pull-to-refresh لتحديث البيانات
- Loading states أثناء العمليات
- رسائل نجاح/خطأ واضحة

## 🔒 الأمان والتحقق

### 1. التحقق من البيانات
- التأكد من ملكية الفاتورة للمستخدم
- التحقق من صحة البيانات المدخلة
- منع التلاعب في المبالغ

### 2. صلاحيات الوصول
- كل مستخدم يرى فواتيره فقط
- التحقق من الهوية في كل عملية

## 📊 التقارير والإحصائيات

### 1. ملخص سريع
- عدد الفواتير في كل حالة
- إجمالي المبالغ المستحقة
- آخر عمليات الدفع

### 2. الفلترة والبحث
- فلترة حسب التاريخ
- بحث برقم الفاتورة
- ترتيب حسب المبلغ أو التاريخ

## ✅ خطوات التنفيذ

1. ✅ **إنشاء الخطة** (مكتمل)
2. ✅ **حذف الجداول القديمة** (مكتمل)
3. ✅ **إنشاء الجداول الجديدة** (مكتمل)
4. ✅ **إنشاء الدوال والتريجرز** (مكتمل)
5. ✅ **إنشاء الصفحات الثلاث** (مكتمل)
6. 🔄 **تصميم شاشة الدفع المنبثقة** (قيد التطوير)
7. 🔄 **اختبار النظام** (قيد التقييم)
8. 🔄 **التحسينات النهائية** (قيد الانتظار)

## 📊 حالة المشروع الحالية

### ✅ ما تم إنجازه:
- ✅ حذف جداول `batch_bills` و `batch_bill_items`
- ✅ إنشاء جدول `bill_payment_requests`
- ✅ إنشاء جدول `paid_bills`
- ✅ تبسيط جدول `bills` الرئيسي
- ✅ إنشاء دالة `submit_bill_payment_request`
- ✅ إنشاء دالة `get_unpaid_bills`
- ✅ إنشاء دالة `get_bills_under_review`
- ✅ إنشاء دالة `get_paid_bills`
- ✅ إنشاء دالة `approve_payment_request`
- ✅ إنشاء تريجر الإشعارات
- ✅ إنشاء صفحة `unpaid_bills_page.dart`
- ✅ إنشاء صفحة `under_review_bills_page.dart`
- ✅ إنشاء صفحة `paid_bills_page.dart`
- ✅ إنشاء صفحة `bills_main_page.dart` الرئيسية
- ✅ إنشاء شاشة الدفع المنبثقة المتطورة `payment_bottom_sheet.dart`
- ✅ تطبيق الأنيميشن والتصميم المطلوب
- ✅ إنشاء نظام خطوات الدفع (اختيار البنك → رفع الصورة → رقم الإيصال → التأكيد)

### 🔄 ما يحتاج للتطوير:
- 🔄 تطبيق رفع الصور الفعلي (image_picker)
- 🔄 عارض الصور (photo_view)
- 🔄 وظيفة تحميل الإيصالات (PDF generation)
- 🔄 ربط الصفحات بالتطبيق الرئيسي (navigation)
- 🔄 إضافة إشعارات الدفع المباشرة
- 🔄 تطوير لوحة تحكم المدير لتأكيد الدفعات

### 🧪 اختبارات قاعدة البيانات:
- ✅ دالة `get_unpaid_bills` - تعمل بنجاح (4 فواتير)
- ✅ دالة `get_bills_under_review` - تعمل (بدون نتائج حالياً)
- ✅ دالة `get_paid_bills` - تعمل (بدون نتائج حالياً)
- ✅ دالة `submit_bill_payment_request` - جاهزة للاختبار
- ✅ دالة `approve_payment_request` - جاهزة للاختبار

### 📱 الملفات المُنشأة:
```
lib/presentation/pages/bills/
├── bills_main_page.dart        # الصفحة الرئيسية مع التبويبات
├── unpaid_bills_page.dart      # الفواتير غير المدفوعة + زر الدفع
├── under_review_bills_page.dart # الفواتير تحت المراجعة
└── paid_bills_page.dart        # الفواتير المدفوعة

lib/presentation/widgets/
└── payment_bottom_sheet.dart   # شاشة الدفع المنبثقة المتطورة

المستندات:
├── BILLS_REDESIGN_PLAN.md      # خطة التطوير الشاملة
└── BILLS_TESTING.md            # اختبارات قاعدة البيانات
```

---
**📝 ملاحظة**: سيتم الاحتفاظ بصفحة الفواتير الحالية كمرجع أثناء التطوير.
