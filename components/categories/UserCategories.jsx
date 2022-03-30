import { createStyles, Table, Title } from "@mantine/core";
import { CategoriesDropdown } from "components/transactions/CategoriesDropdown";
import { SubCategoriesDropdown } from "components/transactions/SubCategoriesSelect";
import { groupBy } from "formatting";
import { useApi } from "hooks/useApi";

import React, { Fragment, useEffect, useRef, useState } from "react";

export default function UserCategories() {
  const useStyles = createStyles((theme) => ({
    table: {
      width: "auto",
      td: {
        paddingTop: "2px !important",
        paddingBottom: "2px !important",
        borderBottom: "0 !important",
      },
    },
    category: {
      fontWeight: 600,
    },
    subcategory: {
      paddingLeft: `${theme.spacing.lg}px !important`,
    },
  }));

  const { classes, cx } = useStyles();

  const { isLoading, error, data } = useApi({
    url: "usercategories",
  });

  // useEffect(() => {
  //   console.log("data", data);
  // }, [data]);

  if (error) {
    return <div>ERROR... {error.message}</div>;
  }

  return (
    <>
      <Title order={3}>Categories</Title>
      <Table highlightOnHover className={cx(classes.table)}>
        <thead>
          <tr>
            <th>Imported As</th>
            <th colSpan={2}>Change To</th>
          </tr>
        </thead>
        <tbody>
          {data &&
            Object.entries(groupBy("imported_category")(data)).map(
              ([key, value]) => {
                return (
                  <Fragment key={key}>
                    <tr>
                      <td className={cx(classes.category)}>{key}</td>
                    </tr>
                    {value.map((subcategory) => {
                      return (
                        <tr key={subcategory.imported_subcategory}>
                          <td className={cx(classes.subcategory)}>
                            {subcategory.imported_subcategory}
                          </td>
                          <td>
                            <div style={{ display: "flex", gap: 4 }}>
                              <CategorySubCategories
                                categoryId={subcategory.category_id}
                                category={subcategory.user_category}
                                subcategory={subcategory.user_subcategory}
                              />
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </Fragment>
                );
              }
            )}
        </tbody>
      </Table>
    </>
  );
}

function CategorySubCategories({ categoryId, category, subcategory }) {
  const [selectedCategory, setSelectedCategory] = useState(category);
  const [selectedSubCategory, setSelectedSubCategory] = useState(subcategory);
  const subcategoryDropdownRef = useRef();
  const onCategorySelected = (value) => {
    if (value === null) return;
    setSelectedCategory(value);
    setSelectedSubCategory(null);
    setTimeout(() => {
      subcategoryDropdownRef?.current?.value = null;
      subcategoryDropdownRef?.current?.focus();
    }, 100);

  };
  return (
    <>
      <CategoriesDropdown
        value={selectedCategory}
        onChange={onCategorySelected}
      />
      <SubCategoriesDropdown
        ref={subcategoryDropdownRef}
        value={selectedSubCategory}
        category={selectedCategory}
        onChange={setSelectedSubCategory}
      />
    </>
  );
}
