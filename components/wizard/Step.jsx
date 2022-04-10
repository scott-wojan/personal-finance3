import React from "react";

export default function Step({
  title,
  label,
  description,
  children,
  loading = false,
}) {
  return (
    <div
      title={title}
      label={label}
      aria-label={label}
      loading={loading}
      description={description}
    >
      {children}
    </div>
  );
}
